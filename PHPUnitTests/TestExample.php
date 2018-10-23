<?php
use PHPUnit\Framework\TestCase;

// This is an example class. When creating your own unit tests, make sure the test class name ends with "Test".

/**
 * Class TestExample
 */
class TestExample extends TestCase
{

    /**
     * @return array
     */
    public function testEmpty()
    {
        $stack = [];
        $this->assertEmpty($stack);

        return $stack;
    }


    /**
     * @depends testEmpty
     *
     * @param array $stack
     *
     * @return array
     */
    public function testPush(array $stack)
    {
        array_push($stack, 'foo');
        $this->assertEquals('foo', $stack[count($stack)-1]);
        $this->assertNotEmpty($stack);

        return $stack;
    }


    /**
     * @depends testPush
     *
     * @param array $stack
     */
    public function testPop(array $stack)
    {
        $this->assertEquals('foo', array_pop($stack));
        $this->assertEmpty($stack);
    }
}