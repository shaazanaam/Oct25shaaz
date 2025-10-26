const { prisma } = require('../utils/prisma');

async function listUsers(req, res, next) {
  try {
    const users = await prisma.user.findMany({ orderBy: { id: 'asc' } });
    res.json(users);
  } catch (err) { next(err); }
}

async function createUser(req, res, next) {
  try {
    const { email, name } = req.body;
    if (!email) return res.status(400).json({ error: 'email is required' });
    const user = await prisma.user.create({ data: { email, name } });
    res.status(201).json(user);
  } catch (err) { next(err); }
}

module.exports = { listUsers, createUser };
