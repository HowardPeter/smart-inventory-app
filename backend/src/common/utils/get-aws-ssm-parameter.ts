import {
  GetParameterCommand,
  GetParametersCommand,
  SSMClient,
} from '@aws-sdk/client-ssm';
import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../errors/custom-error.js';

const ssmClient = new SSMClient({});

type ApiSecrets = {
  databaseUrl: string;
  supabaseServiceRoleKey: string;
  redisUrl: string;
  groqApiKey: string;
  firebaseServiceAccountKey: string;
};

type CronSecrets = {
  databaseUrl: string;
  firebaseServiceAccountKey: string;
};

let cachedApiSecrets: Promise<ApiSecrets> | undefined;
let cachedCronSecrets: Promise<CronSecrets> | undefined;

// Gọi ở ngoài để store cache và tránh `new Map()` ở các lần gọi sau
const directParameterCache = new Map<string, Promise<string>>();

// Lấy value của một biến env bắt buộc trong lambda function
// Vd: DATABASE_URL_PARAMETER=/storix/prod/database-url --> return "/storix/prod/database-url"
const getRequiredEnvironmentVariable = (name: string): string => {
  const value = process.env[name];

  if (!value) {
    throw new CustomError({
      status: StatusCodes.INTERNAL_SERVER_ERROR,
      message: `Required environment variable "${name}" is not configured`,
      isOperational: false,
    });
  }

  return value;
};

const getParameterValues = async (
  parameterNames: string[],
): Promise<Map<string, string>> => {
  let result;

  try {
    result = await ssmClient.send(
      new GetParametersCommand({
        Names: parameterNames,
        WithDecryption: true,
      }),
    );
  } catch (error: unknown) {
    throw new CustomError({
      status: StatusCodes.INTERNAL_SERVER_ERROR,
      message: 'Failed to load application secrets',
      isOperational: false,
      details: {
        Error: error,
      },
    });
  }

  if (result.InvalidParameters?.length) {
    throw new CustomError({
      status: StatusCodes.INTERNAL_SERVER_ERROR,
      message: 'Some required application secrets could not be loaded',
      isOperational: false,
    });
  }

  const parameters = new Map<string, string>();

  for (const parameter of result.Parameters ?? []) {
    if (parameter.Name && parameter.Value) {
      parameters.set(parameter.Name, parameter.Value);
    }
  }

  return parameters;
};

const getParameterValue = (
  parameters: Map<string, string>,
  parameterName: string,
): string => {
  const parameterValue = parameters.get(parameterName);

  if (parameterValue === undefined) {
    throw new CustomError({
      status: StatusCodes.INTERNAL_SERVER_ERROR,
      message: 'Required application secret was not returned by SSM',
      isOperational: false,
    });
  }

  return parameterValue;
};

const loadApiSecrets = async (): Promise<ApiSecrets> => {
  // Đọc toàn bộ các SSM Parameter name được cấu hình thông qua biến env
  // NOTE: Lambda function phải cấu hình sẵn các biến env là SSM Parameter name cần thiết
  const databaseUrlParameter = getRequiredEnvironmentVariable(
    'DATABASE_URL_PARAMETER',
  );
  const supabaseServiceRoleKeyParameter = getRequiredEnvironmentVariable(
    'SUPABASE_SERVICE_ROLE_KEY_PARAMETER',
  );
  const redisUrlParameter = getRequiredEnvironmentVariable(
    'REDIS_URL_PARAMETER',
  );
  const groqApiKeyParameter = getRequiredEnvironmentVariable(
    'GROQ_API_KEY_PARAMETER',
  );
  const firebaseServiceAccountKeyParameter = getRequiredEnvironmentVariable(
    'FIREBASE_SERVICE_ACCOUNT_PARAMETER',
  );

  const parameterNames = [
    databaseUrlParameter,
    supabaseServiceRoleKeyParameter,
    redisUrlParameter,
    groqApiKeyParameter,
    firebaseServiceAccountKeyParameter,
  ];

  const parameters = await getParameterValues(parameterNames);

  return {
    databaseUrl: getParameterValue(parameters, databaseUrlParameter),
    supabaseServiceRoleKey: getParameterValue(
      parameters,
      supabaseServiceRoleKeyParameter,
    ),
    redisUrl: getParameterValue(parameters, redisUrlParameter),
    groqApiKey: getParameterValue(parameters, groqApiKeyParameter),
    firebaseServiceAccountKey: getParameterValue(
      parameters,
      firebaseServiceAccountKeyParameter,
    ),
  };
};

const loadCronSecrets = async (): Promise<CronSecrets> => {
  const databaseUrlParameter = getRequiredEnvironmentVariable(
    'DATABASE_URL_PARAMETER',
  );
  const firebaseServiceAccountKeyParameter = getRequiredEnvironmentVariable(
    'FIREBASE_SERVICE_ACCOUNT_PARAMETER',
  );

  const parameterNames = [
    databaseUrlParameter,
    firebaseServiceAccountKeyParameter,
  ];

  const parameters = await getParameterValues(parameterNames);

  return {
    databaseUrl: getParameterValue(parameters, databaseUrlParameter),
    firebaseServiceAccountKey: getParameterValue(
      parameters,
      firebaseServiceAccountKeyParameter,
    ),
  };
};

/**
 * Lấy toàn bộ application secrets.
 *
 * Secrets chỉ được tải từ AWS SSM đúng một lần
 * trong mỗi Lambda execution environment.
 *
 * Những lần gọi tiếp theo sẽ dùng lại Promise đã cache
 * để tránh phát sinh request SSM không cần thiết.
 *
 * Nếu lần tải đầu tiên thất bại,
 * cache sẽ được xoá để cho phép retry
 * ở lần gọi kế tiếp.
 */
const getApiSecrets = (): Promise<ApiSecrets> => {
  if (!cachedApiSecrets) {
    cachedApiSecrets = loadApiSecrets().catch((error: unknown) => {
      cachedApiSecrets = undefined;

      throw error;
    });
  }

  return cachedApiSecrets;
};

const getCronSecrets = (): Promise<CronSecrets> => {
  if (!cachedCronSecrets) {
    cachedCronSecrets = loadCronSecrets().catch((error: unknown) => {
      cachedCronSecrets = undefined;

      throw error;
    });
  }

  return cachedCronSecrets;
};

export const loadApiSecretsToEnvironment = async (): Promise<void> => {
  const secrets = await getApiSecrets();

  process.env.DATABASE_URL = secrets.databaseUrl;
  process.env.SUPABASE_SERVICE_ROLE_KEY = secrets.supabaseServiceRoleKey;
  process.env.REDIS_URL = secrets.redisUrl;
  process.env.GROQ_API_KEY = secrets.groqApiKey;
  process.env.FIREBASE_SERVICE_ACCOUNT_KEY = secrets.firebaseServiceAccountKey;
};

export const loadCronSecretsToEnvironment = async (): Promise<void> => {
  const secrets = await getCronSecrets();

  process.env.DATABASE_URL = secrets.databaseUrl;
  process.env.FIREBASE_SERVICE_ACCOUNT_KEY = secrets.firebaseServiceAccountKey;
};

// Lấy trực tiếp value 1 Ssm Parameter và cache
export const getDirectSsmParameter = (
  parameterName: string,
): Promise<string> => {
  const cachedParameter = directParameterCache.get(parameterName);

  if (cachedParameter) {
    return cachedParameter;
  }

  const parameterPromise = ssmClient
    .send(
      new GetParameterCommand({
        Name: parameterName,
        WithDecryption: true,
      }),
    )
    .then((response) => {
      if (response.Parameter?.Value === undefined) {
        throw new CustomError({
          status: StatusCodes.INTERNAL_SERVER_ERROR,
          message: 'Required SSM parameter is empty or unavailable',
          isOperational: false,
        });
      }

      return response.Parameter.Value;
    })
    .catch((error: unknown) => {
      directParameterCache.delete(parameterName);

      throw error;
    });

  directParameterCache.set(parameterName, parameterPromise);

  return parameterPromise;
};
