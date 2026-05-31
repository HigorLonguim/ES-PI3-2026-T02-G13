// Autoria: Felipe Sousa - RA: 22018160
import { Router } from "express";
import * as startupController from "../controller/startupController";

const router = Router();

router.get("/", startupController.list);

export default router;
