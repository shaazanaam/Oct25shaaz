function getHealth(req, res) {
  res.json({ status: 'ok', uptime: process.uptime() });
}

function postEcho(req, res) {
  res.json({ you_sent: req.body });
}

module.exports = { getHealth, postEcho };
