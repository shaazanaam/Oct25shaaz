const { Router } = require('express');
const { listUsers, createUser } = require('../controllers/users.controller');

const router = Router();
router.get('/', listUsers);   // GET /users
router.post('/', createUser); // POST /users

module.exports = router;
