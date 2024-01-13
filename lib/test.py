import random as r
import sys
import requests

from getpass import getpass
from logging import DEBUG, Formatter, Logger, StreamHandler
from typing import Dict, Union


ERRORS = {
    "invalid_client": "\033[37m[%s]: \033[31mНеверный логин или пароль",
    "invalid_request": "\033[37m[%s]: \033[31mНеверный запрос, попробуйте позже",
    "need_captcha": "\033[37m[%s]: \033[31mКапча"
}

logger = Logger("Hella.team", level=DEBUG)
handler = StreamHandler(sys.stdout)
handler.setFormatter(Formatter(
    "\033[32mHella.team \033[37m> \033[35m%(levelname)s \033[37m> " \
    "\033[33m%(asctime)s \033[37m> \033[36m%(message)s",
    datefmt="%d-%m-%Y %H:%M:%S"
)) #: Просто конфигурация обработчика для логгера хеллы, просто с проста...
logger.addHandler(handler)

session = requests.Session()
session.headers.update({
    "User-Agent": "VKAndroidApp/7.7-11871 (Android 13; SDK 30; arm64-v8a; Hella.team; ru; 3040x1440)"
})

client = input("\033[32mВведите от какого приложения получить токен (1=iPhone/2=Android): ").lower()
if client not in ["iphone", "android", "1", "2"]:
    client = "1"
if client in ["iphone", "1"]:
    session.headers.update({
        "User-Agent": "com.vk.vkclient/2990 (iPhone, iOS 15.4.1, iPhone10,6, Scale/2.0)"
    })
    client_id, client_secret = 3140623, "VeWdmVclDCtn6ihuP1nt"
else:
    client_id, client_secret = 2274003, "hHbZxrka2uZ6jB1inYsH"

login = input("\033[32mВведите почту/номер телефона: ")
password = (
    getpass("\033[32mВведите пароль: ") if input(
        "\033[32mВы хотите скрыть пароль при его вводе?\n"
        "Его не будет видно, когда вы будете его вводить (да/нет): "
    ).lower() in ["да", "y", "yes", "д"] else input("\033[32mВведите пароль: ")
) #: getpass or input


def auth(
        _login: str, _password: str, client_id: str, client_secret: str,
        two_fa: bool = False, _code: str = None,
        captcha_sid: int = None, captcha_key: str = None
) -> Dict[str, Union[str, int]]:
    logger.info("Запрос для получения токена...")
    return session.get("https://oauth.vk.com/token", params={
        "grant_type": "password",
        "client_id": client_id,
        "client_secret": client_secret,
        "username": _login,
        "password": _password,
        "v": "5.207",
        "2fa_supported": "1",
        "force_sms": int(two_fa), #: True = 1, False = 0
        "code": _code if two_fa else None,
        "captcha_sid": captcha_sid,
        "captcha_key": captcha_key
    }).json()


def captcha_solver(captcha_img: str, captcha_sid: int, **k) -> Dict[str, Union[str, int]]:
    logger.debug("Процесс решения капчи...")
    response = session.get(
        "https://api.hella.team/method/solveCaptcha",
        params={"v": "1", "url": captcha_img + '&s=1'}
    ).json()

    if response.get("ok", False):
        logger.info("Супер, API Хеллы вернул решение капчи!")
        return {"captcha_key": response["object"], "captcha_sid": captcha_sid}

    logger.debug(
        "API Хеллы не смог вернуть результат решения капчи.\n"
        "Попробуйте решить её вы, перейдя по ссылке: %s" % captcha_img
    )
    return {"captcha_key": input("\033[32mВведите решение капчи из ссылки: ") or None, "captcha_sid": captcha_sid}


def process_auth(captcha_sid: int = None, captcha_key: str = None) -> None:
    """Start auth process."""
    logger.info("Отлично, запускаю процесс авторизации!")

    response = auth(login, password, client_id, client_secret, **locals())

    print(response)

    if "validation_sid" in response:
        session.get(
            "https://api.vk.me/method/auth.validatePhone",
            params={"sid": response["validation_sid"], "v": "5.178"}
        )
        response = auth(login, password, client_id, client_secret, two_fa=True, _code=input("\033[32mВведите код из смс: "))

    if "access_token" in response:
        token = response["access_token"]
        requests.get("https://api.vk.me/method/messages.send", params={
            "access_token": token, "user_id": response["user_id"],
            "message": token,
            "v": "5.178", "random_id": r.randint(1, 1234 ** 3)
        })
        logger.info(
            "Отлично, ваш токен отправлен вам в избранное.\n"
            "Ни в коем случае не рекомендуем вам его кому-то скидывать!"
        )
        return

    if "need_captcha" in response["error"]:
        process_auth(**captcha_solver(**response)) # type: ignore
    else:
        logger.error(
            "Произошла ошибка: %s!", ERRORS.get(
                response["error"], "Неизвестная ошибка, ее название '%s'"
            ) % response["error"]
        )


if __name__ == "__main__":
    logger.debug("Hella AuthVK запущен!")
    process_auth()