<?php

function xdd()
{
    if (func_num_args() === 0) {
        exit;
    }

    $arguments = func_get_args();

    if (count($arguments) === 1) {
        $arguments = $arguments[0];
    }

    /** @noinspection ForgottenDebugOutputInspection */
    var_dump($arguments);
    exit;
}

function dd()
{
    if (func_num_args() === 0) {
        exit;
    }

    $arguments = func_get_args();

    if (count($arguments) === 1) {
        $arguments = $arguments[0];
    }

    print_r2($arguments);
    exit;
}

/**
 * @param      $name
 * @param null $default
 *
 * @return array|false|null|string
 */
function env($name, $default = null)
{
    $value = getenv($name);

    if ($value !== false) {
        return $_ENV[$name];
    }

    return $default;
}

/**
 * @param $a
 * @param bool $return
 * @return string
 */
function print_r2($a, $return = false)
{
    if (!headers_sent()) {
        header('Content-Type: text/html');
    }

    $str = '<pre>' . print_r($a, true) . '</pre>';

    if ($return) {
        return $str;
    }

    echo PHP_EOL . $str . PHP_EOL;
}
