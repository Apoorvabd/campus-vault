import {Router} from 'express';
import { register, login, refreshToken, getMe, logout } from './auth.controller';
import { authenticate ,validate} from '../../middleware';
import { registerSchema, loginSchema , refreshTokenSchema} from './auth.validation';
const router = Router();

router.post('/register', validate({body: registerSchema}), register);
router.post('/login', validate({body: loginSchema}), login);
router.post('/refresh-token', validate({body: refreshTokenSchema}), refreshToken);
router.get('/me', authenticate, getMe);
router.post('/logout', authenticate, logout);


export default router;