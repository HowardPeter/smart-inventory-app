import { StoreController } from './controllers/store.controller.js';
import { StoreMemberRepository } from './repositories/store-member.repository.js';
import { StoreRepository } from './repositories/store.repository.js';
import { StoreMemberService } from './services/store-member.service.js';
import { StoreService } from './services/store.service.js';
import { prisma } from '../../db/prismaClient.js';

const storeRepository = new StoreRepository(prisma);
const storeService = new StoreService(storeRepository);
const storeController = new StoreController(storeService);

const storeMemberRepository = new StoreMemberRepository(prisma);
const storeMemberService = new StoreMemberService(storeMemberRepository);

export { storeController, storeMemberService };
