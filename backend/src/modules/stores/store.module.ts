import { StoreMemberRepository } from './repositories/store-member.repository.js';
import { StoreMemberService } from './services/store-member.service.js';

const storeMemberRepository = new StoreMemberRepository();

export const storeMemberService = new StoreMemberService(storeMemberRepository);
