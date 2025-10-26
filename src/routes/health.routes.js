const { Router } = require('express');
const { getHealth, postEcho } = require('../controllers/health.controller');

const router = Router();
router.get('/', getHealth);      // GET /health
router.post('/echo', postEcho);  // POST /health/echo

module.exports = router;
