const { Router } = require('express');
const healthRoutes = require('./health.routes');
const usersRoutes = require('./users.routes');

const router = Router();
router.use('/health', healthRoutes);
router.use('/users', usersRoutes);

module.exports = router;