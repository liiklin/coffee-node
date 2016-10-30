express = require('express')
router = express.Router()

router.get '/', (req, res) ->
  resObj =
    title:"首页"
  res.render "index" ,resObj

module.exports = router
