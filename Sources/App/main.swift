
let config = try Config()
try config.setup()

let drop = try Droplet(config)

/// 基础api
let api   = drop.grouped("api")
let v1    = api.grouped("v1")
let token = v1.grouped(TokenMiddleware())
///sign业务
let signController  = SignController()
signController.registeredRouting()
///user业务
let userController  = UserController()
userController.registeredRouting()
///load业务
let loadController  = LoadController()
loadController.registeredRouting()
///around业务
let aroundController = AroundController()
aroundController.registeredRouting()

//try drop.setup()
try drop.run()


