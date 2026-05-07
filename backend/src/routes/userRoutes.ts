import { Router } from "express";
import { register, login, recoverPassword } from "../controller/userController";

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.post("/recover-password", recoverPassword);

export default router;