import { UserProfileRepository } from './repositories/user-profile.repository.js';
import { UserProfileService } from './services/user-profile.service.js';
import { UserFacade } from './user.facade.js';

const userProfileRepository = new UserProfileRepository();
const userProfileService = new UserProfileService(userProfileRepository);

export const userFacade = new UserFacade(userProfileService);
