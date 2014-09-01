zlib                  = require 'compress-buffer'
traverse              = require 'traverse'
log                   = console.log
fs                    = require 'fs'

Configuration = (options={}) ->

  options.hostname       = "prod.koding.com"
  options.publicHostname = "https://#{options.hostname}"

  cloudamqp           = "golden-ox.rmq.cloudamqp.com"

  hostname            = options.hostname       or "koding.com"
  publicHostname      = options.publicHostname or "https://koding.com"
  region              = "aws"
  configName          = "prod"
  environment         = "production"
  projectRoot         = options.projectRoot    or "/opt/koding"
  version             = options.tag
  tag                 = options.tag
  publicIP            = options.publicIP       or "*"
  githubuser          = options.githubuser     or "koding"

  mongo               = "dev:k9lc4G1k32nyD72@sjc-mongos1.objectrocket.com:14129/koding"
  etcd                = "10.0.0.126:4001,10.0.0.127:4001,10.0.0.128:4001"

  redis               = { host:     "prod0.1ia3pb.0001.use1.cache.amazonaws.com"     , port:               "6379"                                , db:              0                    }
  rabbitmq            = { host:     "#{cloudamqp}"                                   , port:               5672                                  , apiPort:         15672                  , login:           "hcaxnooc"                           , password: "9Pr_d8uxHZMr8w--0FiLDR8Fkwjh7YNF"  , vhost: "hcaxnooc" }
  mq                  = { host:     "#{rabbitmq.host}"                               , port:               rabbitmq.port                         , apiAddress:      "#{rabbitmq.host}"     , apiPort:         "#{rabbitmq.apiPort}"                , login:    "#{rabbitmq.login}"    , componentUser: "#{rabbitmq.login}"                                   , password:       "#{rabbitmq.password}"                                , heartbeat:       0           , vhost:        "#{rabbitmq.vhost}" }
  customDomain        = { public:   "https://#{hostname}"                            , public_:            "#{hostname}"                         , local:           "http://localhost"     , local_:          "localhost"                          , port:     80                   }
  sendgrid            = { username: "koding"                                         , password:           "DEQl7_Dr"                          }
  email               = { host:     "#{customDomain.public_}"                        , protocol:           'https:'                              , defaultFromMail: 'hello@koding.com'     , defaultFromName: 'koding'                             , username: sendgrid.username      , password:      sendgrid.password                                     , forcedRecipient: undefined }
  kontrol             = { url:      "#{options.publicHostname}/kontrol/kite"         , port:               4000                                  , useTLS:          no                     , certFile:        ""                                   , keyFile:  ""                     , publicKeyFile: "#{projectRoot}/certs/test_kontrol_rsa_public.pem"    , privateKeyFile: "#{projectRoot}/certs/test_kontrol_rsa_private.pem" }
  broker              = { name:     "broker"                                         , serviceGenericName: "broker"                              , ip:              ""                     , webProtocol:     "https:"                             , host:     customDomain.public    , port:          8008                                                  , certFile:       ""                                                    , keyFile:         ""          , authExchange: "auth"                , authAllExchange: "authAll" , failoverUri: customDomain.public }
  regions             = { kodingme: "#{configName}"                                  , vagrant:            "vagrant"                             , sj:              "sj"                   , aws:             "aws"                                , premium:  "vagrant"            }
  algolia             = { appId:    '8KD9RHY1OA'                                     , apiKey:             'e4a8ebe91bf848b67c9ac31a6178c64b'    , indexSuffix:     ''                   }
  algoliaSecret       = { appId:    algolia.appId                                    , apiKey:             algolia.apiKey                        , indexSuffix:     algolia.indexSuffix    , apiSecretKey:    '041427512bcdcd0c7bd4899ec8175f46' }
  mixpanel            = { token:    "3d7775525241b3350e6d89bd40031862"               , enabled:            yes                                 }
  postgres            = { host:     "prod0.cfbuweg6pdxe.us-east-1.rds.amazonaws.com" , port:               5432                                  , username:        "socialapplication"    , password:        "socialapplication"                  , dbname:   "social"             }
  # this is set to kite_home/koding intentionally, because of the usage of
  # localhost:4000
  kiteHome            = "#{projectRoot}/kite_home/koding"

  # configuration for socialapi, order will be the same with
  # ./go/src/socialapi/config/configtypes.go
  socialapiProxy      =
    hostname          : "localhost"
    port              : "7000"

  socialapi =
    proxyUrl          : "http://#{socialapiProxy.hostname}:#{socialapiProxy.port}"
    configFilePath    : "#{projectRoot}/go/src/socialapi/config/prod.toml"
    postgres          : postgres
    mq                : mq
    redis             :  url: "#{redis.host}:#{redis.port}"
    mongo             : mongo
    environment       : environment
    region            : region
    hostname          : hostname
    email             : email
    sitemap           : { redisDB: 0 }
    algolia           : algoliaSecret
    mixpanel          : mixpanel
    limits            : { messageBodyMinLen: 1, postThrottleDuration: "15s", postThrottleCount: "3" }
    eventExchangeName : "BrokerMessageBus"
    disableCaching    : no
    debug             : no

  userSitesDomain     = "koding.io"
  socialQueueName     = "koding-social-#{configName}"
  logQueueName        = socialQueueName+'log'

  KONFIG              =
    environment                    : environment
    regions                        : regions
    region                         : region
    hostname                       : hostname
    publicHostname                 : publicHostname
    version                        : version
    broker                         : broker
    uri                            : {address: "#{customDomain.public}:#{customDomain.port}"}
    userSitesDomain                : userSitesDomain
    projectRoot                    : projectRoot
    socialapi                      : socialapi
    mongo                          : mongo
    kiteHome                       : kiteHome
    redis                          : "#{redis.host}:#{redis.port}"
    misc                           : {claimGlobalNamesForUsers: no , updateAllSlugs : no , debugConnectionErrors: yes}

    # -- WORKER CONFIGURATION -- #

    webserver                      : {port          : 3000                        , useCacheHeader: no                      , kitePort          : 8860 }
    authWorker                     : {login         : "#{rabbitmq.login}"         , queueName : socialQueueName+'auth'      , authExchange      : "auth"                                  , authAllExchange : "authAll"}
    mq                             : mq
    emailWorker                    : {cronInstant   : '*/10 * * * * *'            , cronDaily : '0 10 0 * * *'              , run               : yes                                     , forcedRecipient : email.forcedRecipient               , maxAge: 3 }
    elasticSearch                  : {host          : "localhost"                 , port      : 9200                        , enabled           : no                                      , queue           : "elasticSearchFeederQueue"}
    social                         : {port          : 3030                        , login     : "#{rabbitmq.login}"         , queueName         : socialQueueName                         , kitePort        : 8760 }
    email                          : email
    newkites                       : {useTLS        : no                          , certFile  : ""                          , keyFile: "#{projectRoot}/kite_home/production/kite.key"}
    log                            : {login         : "#{rabbitmq.login}"         , queueName : logQueueName}
    boxproxy                       : {port          : 80 }
    sourcemaps                     : {port          : 3526 }
    appsproxy                      : {port          : 3500 }

    kloud                          : {port          : 5500                        , privateKeyFile : kontrol.privateKeyFile , publicKeyFile: kontrol.publicKeyFile                        , kontrolUrl: kontrol.url                              , registerUrl : "#{customDomain.public}/kloud/kite" }

    emailConfirmationCheckerWorker : {enabled: no                                 , login : "#{rabbitmq.login}"             , queueName: socialQueueName+'emailConfirmationCheckerWorker' , cronSchedule: '0 * * * * *'                           , usageLimitInMinutes  : 60}

    kontrol                        : kontrol
    newkontrol                     : kontrol

    # -- MISC SERVICES --#
    recurly                        : {apiKey        : '4a0b7965feb841238eadf94a46ef72ee'             , loggedRequests: "/^(subscriptions|transactions)/"}
    sendgrid                       : sendgrid
    opsview                        : {push          : no                                             , host          : ''                                           , bin: null                                                                             , conf: null}
    github                         : {clientId      : "f8e440b796d953ea01e5"                         , clientSecret  : "b72e2576926a5d67119d5b440107639c6499ed42"}
    odesk                          : {key           : "639ec9419bc6500a64a2d5c3c29c2cf8"             , secret        : "549b7635e1e4385e"                           , request_url: "https://www.odesk.com/api/auth/v1/oauth/token/request"                  , access_url: "https://www.odesk.com/api/auth/v1/oauth/token/access" , secret_url: "https://www.odesk.com/services/api/auth?oauth_token=" , version: "1.0"                                                    , signature: "HMAC-SHA1" , redirect_uri : "#{customDomain.host}:#{customDomain.port}/-/oauth/odesk/callback"}
    facebook                       : {clientId      : "475071279247628"                              , clientSecret  : "65cc36108bb1ac71920dbd4d561aca27"           , redirectUri  : "#{customDomain.host}:#{customDomain.port}/-/oauth/facebook/callback"}
    google                         : {client_id     : "1058622748167.apps.googleusercontent.com"     , client_secret : "vlF2m9wue6JEvsrcAaQ-y9wq"                   , redirect_uri : "#{customDomain.host}:#{customDomain.port}/-/oauth/google/callback"}
    twitter                        : {key           : "aFVoHwffzThRszhMo2IQQ"                        , secret        : "QsTgIITMwo2yBJtpcp9sUETSHqEZ2Fh7qEQtRtOi2E" , redirect_uri : "#{customDomain.host}:#{customDomain.port}/-/oauth/twitter/callback"   , request_url  : "https://twitter.com/oauth/request_token"           , access_url   : "https://twitter.com/oauth/access_token"            , secret_url: "https://twitter.com/oauth/authenticate?oauth_token=" , version: "1.0"         , signature: "HMAC-SHA1"}
    linkedin                       : {client_id     : "f4xbuwft59ui"                                 , client_secret : "fBWSPkARTnxdfomg"                           , redirect_uri : "#{customDomain.host}:#{customDomain.port}/-/oauth/linkedin/callback"}
    slack                          : {token         : "xoxp-2155583316-2155760004-2158149487-a72cf4" , channel       : "C024LG80K"}
    statsd                         : {use           : false                                          , ip            : "#{customDomain.host}"                       , port: 8125}
    graphite                       : {use           : false                                          , host          : "#{customDomain.host}"                       , port: 2003}
    sessionCookie                  : {maxAge        : 1000 * 60 * 60 * 24 * 14                       , secure        : no}
    logLevel                       : {neo4jfeeder   : "notice"                                       , oskite: "info"                                               , terminal: "info"                                                                      , kontrolproxy  : "notice"                                           , kontroldaemon : "notice"                                           , userpresence  : "notice"                                          , vmproxy: "notice"      , graphitefeeder: "notice"                                                           , sync: "notice" , topicModifier : "notice" , postModifier  : "notice" , router: "notice" , rerouting: "notice" , overview: "notice" , amqputil: "notice" , rabbitMQ: "notice" , ldapserver: "notice" , broker: "notice"}
    aws                            : {key           : 'AKIAJSUVKX6PD254UGAA'                         , secret        : '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'}
    embedly                        : {apiKey        : '94991069fb354d4e8fdb825e52d4134a'}
    troubleshoot                   : {recipientEmail: "can@koding.com"}
    rollbar                        : "71c25e4dc728431b88f82bd3e7a600c9"
    mixpanel                       : mixpanel.token
    recaptcha                      : '6LfFAPcSAAAAAPmec0-3i_hTWE8JhmCu_JWh5h6e'
    segment                        : '4c570qjqo0'

    #--- CLIENT-SIDE BUILD CONFIGURATION ---#

    client                         : {watch: yes , version       : version , includesPath:'client' , indexMaster: "index-master.html" , index: "default.html" , useStaticFileServer: no , staticFilesBaseUrl: "#{customDomain.public}:#{customDomain.port}"}

  #-------- runtimeOptions: PROPERTIES SHARED WITH BROWSER --------#
  KONFIG.client.runtimeOptions =
    kites             : require './kites.coffee'           # browser passes this version information to kontrol , so it connects to correct version of the kite.
    algolia           : algolia
    logToExternal     : no                                 # rollbar , mixpanel etc.
    suppressLogs      : no
    logToInternal     : no                                 # log worker
    authExchange      : "auth"
    environment       : environment                        # this is where browser knows what kite environment to query for
    version           : version
    resourceName      : socialQueueName
    userSitesDomain   : userSitesDomain
    logResourceName   : logQueueName
    socialApiUri      : "/xhr"
    apiUri            : "/"
    mainUri           : "/"
    sourceMapsUri     : "/sourcemaps"
    broker            : {uri          : "/subscribe" }
    appsUri           : "https://rest.kd.io"
    uploadsUri        : 'https://koding-uploads.s3.amazonaws.com'
    uploadsUriForGroup: 'https://koding-groups.s3.amazonaws.com'
    fileFetchTimeout  : 1000 * 15
    userIdleMs        : 1000 * 60 * 5
    embedly           : {apiKey       : "94991069fb354d4e8fdb825e52d4134a"     }
    github            : {clientId     : "f8e440b796d953ea01e5" }
    newkontrol        : {url          : "/kontrol/kite"}
    sessionCookie     : {maxAge       : 1000 * 60 * 60 * 24 * 14  , secure: no   }
    troubleshoot      : {idleTime     : 1000 * 60 * 60            , externalUrl  : "https://s3.amazonaws.com/koding-ping/healthcheck.json"}
    recaptcha         : '6LfFAPcSAAAAAHRGr1Tye4tD-yLz0Ll-EN0yyQ6l'
    externalProfiles  :
      google          : {nicename: 'Google'  }
      linkedin        : {nicename: 'LinkedIn'}
      twitter         : {nicename: 'Twitter' }
      odesk           : {nicename: 'oDesk'   , urlLocation: 'info.profile_url' }
      facebook        : {nicename: 'Facebook', urlLocation: 'link'             }
      github          : {nicename: 'GitHub'  , urlLocation: 'html_url'         }

      # END: PROPERTIES SHARED WITH BROWSER #


  #--- RUNTIME CONFIGURATION: WORKERS AND KITES ---#
  GOBIN = "#{projectRoot}/go/bin"


  # THESE COMMANDS WILL EXECUTE SEQUENTIALLY.

  KONFIG.workers =
    kontrol             :
      group             : "environment"
      ports             :
        incoming        : "#{kontrol.port}"
      supervisord       :
        command         : "#{GOBIN}/kontrol -region #{region} -machines #{etcd} -environment #{environment} -mongourl #{KONFIG.mongo} -port #{kontrol.port} -privatekey #{kontrol.privateKeyFile} -publickey #{kontrol.publicKeyFile}"
      nginx             :
        websocket       : yes
        locations       : ["~^/kontrol/.*"]

    kloud               :
      group             : "environment"
      ports             :
        incoming        : "#{KONFIG.kloud.port}"
      supervisord       :
        command         : "#{GOBIN}/kloud -hostedzone #{userSitesDomain} -region #{region} -environment #{environment} -port #{KONFIG.kloud.port} -publickey #{kontrol.publicKeyFile} -privatekey #{kontrol.privateKeyFile} -kontrolurl #{kontrol.url}  -registerurl #{KONFIG.kloud.registerUrl} -mongourl #{KONFIG.mongo} -prodmode=#{configName is "prod"}"
      nginx             :
        websocket       : yes
        locations       : ["~^/kloud/.*"]

    # ngrokProxy          :
    #   group             : "environment"
    #   supervisord       :
    #     command         : "coffee #{projectRoot}/ngrokProxy --user #{publicHostname}"

    # reverseProxy        :
    #   group             : "environment"
    #   supervisord       :
    #     command         : "#{GOBIN}/reverseproxy -port 1234 -env production -region #{publicHostname}PublicEnvironment -publicHost proxy-#{publicHostname}.ngrok.com -publicPort 80"

    broker              :
      group             : "webserver"
      ports             :
        incoming        : "#{KONFIG.broker.port}"
      supervisord       :
        command         : "#{GOBIN}/broker -c #{configName}"
      nginx             :
        websocket       : yes
        locations       : ["/websocket", "~^/subscribe/.*"]

    rerouting           :
      group             : "webserver"
      supervisord       :
        command         : "#{GOBIN}/rerouting -c #{configName}"

    authworker          :
      group             : "webserver"
      instances         : 2
      supervisord       :
        command         : "node #{projectRoot}/workers/auth/index.js -c #{configName} --disable-newrelic"

    sourcemaps          :
      group             : "webserver"
      ports             :
        incoming        : "#{KONFIG.sourcemaps.port}"
      supervisord       :
        command         : "node #{projectRoot}/servers/sourcemaps/index.js -c #{configName} -p #{KONFIG.sourcemaps.port} --disable-newrelic"

    emailsender         :
      group             : "webserver"
      supervisord       :
        command         : "node #{projectRoot}/workers/emailsender/index.js  -c #{configName} --disable-newrelic"

    appsproxy           :
      group             : "webserver"
      ports             :
        incoming        : "#{KONFIG.appsproxy.port}"
      supervisord       :
        command         : "node #{projectRoot}/servers/appsproxy/web.js -c #{configName} -p #{KONFIG.appsproxy.port}"

    webserver           :
      group             : "webserver"
      instances         : 2
      ports             :
        incoming        : "#{KONFIG.webserver.port}"
        outgoing        : "#{KONFIG.webserver.kitePort}"
      instances         : 2
      supervisord       :
        command         : "node #{projectRoot}/servers/index.js -c #{configName} -p #{KONFIG.webserver.port}                  --disable-newrelic --kite-port=#{KONFIG.webserver.kitePort} --kite-key=#{kiteHome}/kite.key"
      nginx             :
        locations       : ["/"]

    socialworker        :
      group             : "webserver"
      instances         : 2
      ports             :
        incoming        : "#{KONFIG.social.port}"
        outgoing        : "#{KONFIG.social.kitePort}"
      supervisord       :
        command         : "node #{projectRoot}/workers/social/index.js -c #{configName} -p #{KONFIG.social.port} -r #{region} --disable-newrelic --kite-port=#{KONFIG.social.kitePort} --kite-key=#{kiteHome}/kite.key"
      nginx             :
        locations       : ["/xhr"]

    guestCleaner        :
      group             : "webserver"
      supervisord       :
        command         : "#{GOBIN}/guestcleanerworker -c #{configName}"

    # clientWatcher       :
    #   group             : "webserver"
    #   supervisord       :
    #     command         : "ulimit -n 1024 && coffee #{projectRoot}/build-client.coffee  --watch --sourceMapsUri /sourcemaps --verbose true"



    # Social API workers
    socialapi:
      group             : "socialapi"
      instances         : 2
      ports             :
        incoming        : "#{socialapiProxy.port}"
      supervisord       :
        command         : "#{GOBIN}/api  -c #{socialapi.configFilePath} -port=#{socialapiProxy.port}"

    dailyemailnotifier  :
      group             : "socialapi"
      supervisord       :
        command         : "#{GOBIN}/dailyemailnotifier -c #{socialapi.configFilePath}"

    notification        :
      group             : "socialapi"
      supervisord       :
        command         : "#{GOBIN}/notification -c #{socialapi.configFilePath}"

    popularpost         :
      group             : "socialapi"
      supervisord       :
        command         : "#{GOBIN}/popularpost -c #{socialapi.configFilePath}"

    populartopic        :
      group             : "socialapi"
      supervisord       :
        command         : "#{GOBIN}/populartopic -c #{socialapi.configFilePath}"

    pinnedpost          :
      group             : "socialapi"
      supervisord       :
        command         : "#{GOBIN}/pinnedpost -c #{socialapi.configFilePath}"

    realtime            :
      group             : "socialapi"
      instances         : 3
      supervisord       :
        command         : "#{GOBIN}/realtime  -c #{socialapi.configFilePath}"

    sitemapfeeder       :
      group             : "socialapi"
      supervisord       :
        command         : "#{GOBIN}/sitemapfeeder -c #{socialapi.configFilePath}"

    sitemapgenerator    :
      group             : "socialapi"
      supervisord       :
        command         : "#{GOBIN}/sitemapgenerator -c #{socialapi.configFilePath}"

    emailnotifier       :
      group             : "socialapi"
      supervisord       :
        command         : "#{GOBIN}/emailnotifier -c #{socialapi.configFilePath}"

    topicfeed           :
      group             : "socialapi"
      supervisord       :
        command         : "#{GOBIN}/topicfeed -c #{socialapi.configFilePath}"

    trollmode           :
      group             : "socialapi"
      supervisord       :
        command         : "#{GOBIN}/trollmode -c #{socialapi.configFilePath}"


    # these are unnecessary on production machines.
    # ------------------------------------------------------------------------------------------
    # clientWatcher       : command : "coffee #{projectRoot}/build-client.coffee    --watch --sourceMapsUri #{hostname}"
    # reverseProxy        : command : "#{GOBIN}/rerun koding/kites/reverseproxy -port 1234 -env production -region #{publicHostname}PublicEnvironment -publicHost proxy-#{publicHostname}.ngrok.com -publicPort 80"
    # kloud               : command : "#{GOBIN}/rerun koding/kites/kloud     -c #{configName} -r #{region} -port #{KONFIG.kloud.port} -public-key #{KONFIG.kloud.publicKeyFile} -private-key #{KONFIG.kloud.privateKeyFile} -kontrol-url \"http://#{KONFIG.kloud.kontrolUrl}\" -debug"
    # kontrol             : command : "#{GOBIN}/rerun koding/kites/kontrol   -c #{configName} -r #{region}"
    # boxproxy            : command : "node   #{projectRoot}/servers/boxproxy/boxproxy.js           -c #{configName}"
    # ngrokProxy          : command : "#{projectRoot}/ngrokProxy --user #{publicHostname}"
    # --port #{kontrol.port} -env #{environment} -public-key #{kontrol.publicKeyFile} -private-key #{kontrol.privateKeyFile}"
    # guestcleaner        : command : "node #{projectRoot}/workers/guestcleaner/index.js     -c #{configName}"
    # ------------------------------------------------------------------------------------------






  #-------------------------------------------------------------------------#
  #---- SECTION: AUTO GENERATED CONFIGURATION FILES ------------------------#
  #---- DO NOT CHANGE ANYTHING BELOW. IT'S GENERATED FROM WHAT'S ABOVE  ----#
  #-------------------------------------------------------------------------#

  KONFIG.JSON = JSON.stringify KONFIG

  b64z = (str,strict=yes,compress=yes)->
    if str
      _b64 = new Buffer(str)
      _b64 = zlib.compress _b64 if compress
      # log "[b64z] before #{str.length} after #{_b64.length}"
      return _b64.toString('base64')
    else
      if strict
        console.trace()
        throw "base64 STRING is empty, check main.#{configName}.coffee. this will break the prod machine, exiting."
      else
        return ""

  prodKeys =
    id_rsa          : fs.readFileSync("./install/keys/prod.ssh/id_rsa","utf8")
    id_rsa_pub      : fs.readFileSync("./install/keys/prod.ssh/id_rsa.pub","utf8")
    authorized_keys : fs.readFileSync("./install/keys/prod.ssh/authorized_keys","utf8")
    config          : fs.readFileSync("./install/keys/prod.ssh/config","utf8")


  generateSupervisorConf = (KONFIG)->
    return (require "../deployment/supervisord.coffee").create KONFIG

  generateRunFile = (KONFIG) ->
    return """
      #!/bin/bash
      export GOPATH=#{projectRoot}/go
      export GOBIN=#{projectRoot}/go/bin
      export HOME=/root
      export KONFIG_JSON='#{KONFIG.JSON}'
      coffee #{projectRoot}/build-client.coffee --watch false
      """

  cloudformation = ->
    AWSTemplateFormatVersion: "2010-09-09"
    Description: "Koding deployment on AWS"
    Resources:
        KodingAutoScale:
            Type: "AWS::AutoScaling::AutoScalingGroup"
            Properties:
                AvailabilityZones: ["us-east-1a"]
                LaunchConfigurationName: {Ref: "KodingLaunchConfig"}
                VPCZoneIdentifier: ["subnet-b47692ed"]
                LoadBalancerNames: ["koding-prod-deployment"]
                MinSize: "3"
                MaxSize: "12"
                DesiredCapacity: "3"
                Tags: [ Key: "Name", Value: {Ref: "AWS::StackName"}, PropagateAtLaunch: yes]

        KodingLaunchConfig:
            Type: "AWS::AutoScaling::LaunchConfiguration"
            Properties:
                ImageId: "ami-864d84ee"
                InstanceType: "t2.micro"
                KeyName: "koding-prod-deployment"
                SecurityGroups: ["sg-64126d01"]
                UserData: "Fn::Base64": run



  machineSettings = ->
    return """
        \n
        echo '#{b64z KONFIG.nginxConf}'               | base64 --decode | gunzip >  /etc/nginx/sites-enabled/default;
        echo "nginx configured."
        echo '#{b64z generateSupervisorConf(KONFIG)}' | base64 --decode | gunzip >  /etc/supervisor/conf.d/koding.conf;
        echo "supervisor configured."
    """

  KONFIG.ENV             = (require "../deployment/envvar.coffee").create KONFIG
  KONFIG.nginxConf       = (require "../deployment/nginx.coffee").create KONFIG.workers, environment
  KONFIG.machineSettings = b64z machineSettings()
  KONFIG.runFile         = generateRunFile KONFIG

  return KONFIG


module.exports = Configuration
