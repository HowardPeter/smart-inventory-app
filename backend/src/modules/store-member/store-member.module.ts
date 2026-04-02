import { StoreMemberController } from './controller/store-member.controller.js';
import { StoreMemberRepository } from './repository/store-member.repository.js';
import { StoreMemberService } from './service/store-member.service.js';

const storeMemberRepository = new StoreMemberRepository();
const storeMemberService = new StoreMemberService(storeMemberRepository);
const storeMemberController = new StoreMemberController(storeMemberService);

export { storeMemberRepository, storeMemberService, storeMemberController };
