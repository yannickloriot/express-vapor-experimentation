import Leaf
import Redis
import Vapor

var databases = DatabasesConfig()
var redisConfig: RedisClientConfig = RedisClientConfig()
redisConfig.hostname = ProcessInfo.processInfo.environment["REDIS_HOSTNAME"] ?? redisConfig.hostname

let redisDatabse = try RedisDatabase(config: redisConfig)
databases.add(database: redisDatabse, as: .redis)

// register providers
var services = Services.default()
try services.register(LeafProvider())
try services.register(RedisProvider())
try services.register(databases)

// Use Leaf for rendering views
var config = Config.default()
config.prefer(LeafRenderer.self, for: ViewRenderer.self)

let app = try Application(config: config, services: services)
let router = try app.make(Router.self)

router.get("/") { req -> Future<View> in
    return req.withNewConnection(to: .redis) { redis in
        return redis.smembers("items").flatMap(to: View.self) { data in
            let items = (data.array ?? []).compactMap { $0.string }
            let context = ["items": items]

            return try req.view().render("home", context)
        }
    }
}

router.get("/delete", String.parameter) { req -> Future<Response> in
    let param = try req.parameters.next(String.self)
    let itemId = param.removingPercentEncoding ?? ""

    return req.withNewConnection(to: .redis) { redis in
        return redis.srem("items", items: [RedisData(bulk: itemId)]).map(to: Response.self) { _ in
            return req.redirect(to: "/")
        }
    }
}

router.post("/") { req -> Future<Response> in
    let itemId = try req.content.syncGet(String.self, at: "title")

    return req.withNewConnection(to: .redis) { redis in
        return redis.sadd("items", items: [RedisData(bulk: itemId)]).map(to: Response.self) { _ in
            return req.redirect(to: "/")
        }
    }
}

try app.run()