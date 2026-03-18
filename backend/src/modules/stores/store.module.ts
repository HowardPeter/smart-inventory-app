import { StoreMemberRepository } from './repositories/store-member.repository.js';
import { StoreRepository } from './repositories/store.repository.js';
import { StoreMemberService } from './services/store-member.service.js';
import { StoreService } from './services/store.service.js';
import { StoreController } from './store.controller.js';

const storeRepository = new StoreRepository();
const storeService = new StoreService(storeRepository);
const storeController = new StoreController(storeService);

const storeMemberRepository = new StoreMemberRepository();
const storeMemberService = new StoreMemberService(storeMemberRepository);

export { storeRepository, storeService, storeController, storeMemberService };
