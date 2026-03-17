import { UserProfileRepository } from './repositories/user-profile.repository.js';
import { UserProfileService } from './services/user-profile.service.js';
import { UserFacade } from './user.facade.js';

// Lớp DI wiring để export cho các module hoặc layer khác sử dụng
const userProfileRepository = new UserProfileRepository();
const userProfileService = new UserProfileService(userProfileRepository);

// Export Facade để sử dụng trong các module khác
export const userFacade = new UserFacade(userProfileService);
