import os
import logging, logging.config
from datetime import datetime


class ScriptLogger(object):
    """
    Author: Charles Goncalves
    github @charlesfg

    Usage:  call the constructor once and get the configured logger
         script_logger = ScriptLogger(__file__)
         logger = script_logger.get_main_logger()


    """
    main_logger = None

    def __init__(self, script_file, level='DEBUG', log_dir=None, extra_info=None, fmt="%Y%m%d_%H%M%S"):
        self.log_time = None
        if ScriptLogger.main_logger is not None:
            return
        else:
            self.log_file = os.path.basename(script_file)[0:-3]
            if extra_info:
                self.log_file = "{}_{}".format(self.log_file, extra_info)
            self.log_time = datetime.now().strftime(fmt)
            self.log_file = "{}_{}".format(self.log_file, self.log_time)

            if log_dir:
                self.log_file = "{}{}{}".format(log_dir, os.sep, self.log_file)

            LOGGING = {
                'version': 1,
                'disable_existing_loggers': False,
                'formatters': {
                    'verbose': {
                        'format': '%(name)s %(levelname)s %(asctime)s %(module)s %(lineno)d %(thread)d %(message)s'
                    },
                    'simple': {
                        'format': '%(name)s %(levelname)s %(message)s'
                    },
                },
                'handlers': {
                    'console': {
                        'level': level,
                        'class': 'logging.StreamHandler',
                        'formatter': 'verbose'
                    },
                    'file': {
                        'level': level,
                        'class': 'logging.handlers.TimedRotatingFileHandler',
                        'filename': '{}.log'.format(self.log_file),
                        'formatter': 'verbose',
                        'when': 'midnight',
                        'backupCount': 30,
                        'delay': False
                    },
                },

                'loggers': {
                    # Might as well log any errors anywhere else in Django
                    '__main__': {
                        'handlers': ['console', 'file'],
                        'level': 'DEBUG',
                        'propagate': True,
                    }
                }
            }

            logging.config.dictConfig(LOGGING)
            ScriptLogger.main_logger = logging.getLogger('__main__')

    @classmethod
    def get_main_logger(cls):
        if ScriptLogger.main_logger is None:
            raise RuntimeError("Logger was not configured (did you call the constructor?)")

        return ScriptLogger.main_logger

    def get_log_file_preffix(self):
        return self.log_file
