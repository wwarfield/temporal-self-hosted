from envyaml import EnvYAML
import os


class BaseConfig:

    def __init__(self):
        default_config_file = 'worker/config/local.yaml'

        override_config = os.getenv('PYYAML_CONFIG')
        if override_config:
            self.config_dict = EnvYAML(override_config)
        else:
            self.config_dict = EnvYAML(default_config_file)


class TemporalConfig(BaseConfig):

    def __init__(self):
        super().__init__()
        self.temporal_config = self.config_dict['temporal']

    def get_server_host(self) -> str:
        return self.temporal_config['server']['host']

    def get_server_port(self) -> str:
        return self.temporal_config['server']['port']
