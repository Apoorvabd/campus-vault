import {Router} from 'express';
import { register, login, refreshToken, getMe, logout, sendEmailVerificationCode, verifyEmailVerificationCode, googleLogin, googleRegister } from './auth.controller';
import { authenticate ,validate, loginLimiter, registerLimiter, refreshTokenLimiter, emailCodeSendLimiter, emailCodeSendIpLimiter, emailCodeVerifyLimiter, googleAuthLimiter} from '../../middleware';
import { registerSchema, loginSchema , refreshTokenSchema, sendEmailCodeSchema, verifyEmailCodeSchema, googleLoginSchema, googleRegisterSchema} from './auth.validation';

const router = Router();

router.post('/google', googleAuthLimiter, validate({body: googleLoginSchema}), googleLogin);
router.post('/google/register', googleAuthLimiter, validate({body: googleRegisterSchema}), googleRegister);

router.post('/email-verification/send', emailCodeSendIpLimiter, emailCodeSendLimiter, validate({body: sendEmailCodeSchema}), sendEmailVerificationCode);
router.post('/email-verification/verify', emailCodeVerifyLimiter, validate({body: verifyEmailCodeSchema}), verifyEmailVerificationCode);

router.post('/register', registerLimiter, validate({body: registerSchema}), register);
router.post('/login', loginLimiter, validate({body: loginSchema}), login);
router.post('/refresh-token', refreshTokenLimiter, validate({body: refreshTokenSchema}), refreshToken);
router.get('/me', authenticate, getMe);
router.post('/logout', authenticate, logout);


export default router;