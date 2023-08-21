#include <memory>
#include <verilated.h>
#include <gtest/gtest.h>

#include "Vtoplev.h"

TEST(TopLev, IncrementsCounter) {
    std::unique_ptr<Vtoplev> tb = std::make_unique<Vtoplev>();
    
    tb->rst = 0;
    tb->eval();
    tb->rst = 1;
    tb->eval();
    tb->rst = 0;
    
    ASSERT_EQ(tb->counter, 0);

    tb->clk = 1;
    tb->eval();
    tb->clk = 0;
    tb->eval();

    ASSERT_EQ(tb->counter, 1);
    
    tb->clk = 1;
    tb->eval();
    tb->clk = 0;
    tb->eval();

    ASSERT_EQ(tb->counter, 2);
    
    tb->clk = 1;
    tb->eval();
    tb->clk = 0;
    tb->eval();

    ASSERT_EQ(tb->counter, 3);
    
    tb->clk = 1;
    tb->eval();
    tb->clk = 0;
    tb->eval();

    ASSERT_EQ(tb->counter, 0);
}

