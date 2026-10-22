import {Router} from 'express';
import { register, login, refreshToken, getMe, logout } from './auth.controller';
import { authenticate ,validate, loginLimiter, registerLimiter, refreshTokenLimiter} from '../../middleware';
import { registerSchema, loginSchema , refreshTokenSchema} from './auth.validation';

const router = Router();

router.post('/register', registerLimiter, validate({body: registerSchema}), register);
router.post('/login', loginLimiter, validate({body: loginSchema}), login);
router.post('/refresh-token', refreshTokenLimiter, validate({body: refreshTokenSchema}), refreshToken);
router.get('/me', authenticate, getMe);
router.post('/logout', authenticate, logout);


export default router;