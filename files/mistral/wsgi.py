from mistral import config
from mistral.api import app
from mistral.engine1 import rpc
from oslo.config import cfg
from oslo.db import options as db_options

db_options.set_defaults(cfg.CONF)
config.parse_args()
transport = rpc.get_transport()

application = app.setup_app(transport=transport)