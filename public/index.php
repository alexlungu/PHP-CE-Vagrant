<?php
/**
 * Created by PhpStorm.
 * User: AlexLungu
 * Date: 23/10/2018
 */

require __DIR__ . '/../helpers/helpers.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

echo '<h1>Event Sourcing For Real</h1>';

$db = new mysqli('localhost', 'root', 'password', 'development');
$res = $db->query('SELECT id FROM tbl_test_table WHERE id = 2');

print_r2($res->fetch_assoc()); exit;

