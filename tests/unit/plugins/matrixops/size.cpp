//   Copyright (c) 2017-2019 Hartmut Kaiser
//   Copyright (c) 2018 Shahrzad Shirzad
//
//   Distributed under the Boost Software License, Version 1.0. (See accompanying
//   file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#include <phylanx/phylanx.hpp>

#include <hpx/hpx_main.hpp>
#include <hpx/include/lcos.hpp>
#include <hpx/modules/testing.hpp>

#include <cstdint>
#include <utility>
#include <vector>

#include <blaze/Math.h>
#include <blaze_tensor/Math.h>

void test_extract_size_0d()
{
    phylanx::execution_tree::primitive arg1 =
        phylanx::execution_tree::primitives::create_variable(
            hpx::find_here(), phylanx::ir::node_data<double>(3.0));

    phylanx::execution_tree::primitive size =
        phylanx::execution_tree::primitives::create_size_operation(
            hpx::find_here(),
            phylanx::execution_tree::primitive_arguments_type{
                std::move(arg1)});

    phylanx::execution_tree::primitive_argument_type f = size.eval().get();

    HPX_TEST_EQ(std::int64_t(1),
        phylanx::execution_tree::extract_scalar_integer_value(f));
}

void test_extract_size_1d()
{
    blaze::Rand<blaze::DynamicVector<double>> gen{};
    blaze::DynamicVector<double> v = gen.generate(1007UL);

    phylanx::execution_tree::primitive arg1 =
        phylanx::execution_tree::primitives::create_variable(
            hpx::find_here(), phylanx::ir::node_data<double>(v));

    phylanx::execution_tree::primitive size =
        phylanx::execution_tree::primitives::create_size_operation(
            hpx::find_here(),
            phylanx::execution_tree::primitive_arguments_type{
                std::move(arg1)});

    phylanx::execution_tree::primitive_argument_type f = size.eval().get();

    HPX_TEST_EQ(std::int64_t(1007),
        phylanx::execution_tree::extract_scalar_integer_value(f));
}

void test_extract_size_2d()
{
    blaze::Rand<blaze::DynamicMatrix<double>> gen{};
    blaze::DynamicMatrix<double> m = gen.generate(101UL, 117UL);

    phylanx::execution_tree::primitive arg1 =
        phylanx::execution_tree::primitives::create_variable(
            hpx::find_here(), phylanx::ir::node_data<double>(m));

    phylanx::execution_tree::primitive size =
        phylanx::execution_tree::primitives::create_size_operation(
            hpx::find_here(),
            phylanx::execution_tree::primitive_arguments_type{
                std::move(arg1)});

    phylanx::execution_tree::primitive_argument_type f = size.eval().get();

    HPX_TEST_EQ(std::int64_t(11817),
        phylanx::execution_tree::extract_scalar_integer_value(f));
}

void test_extract_size_3d()
{
    blaze::Rand<blaze::DynamicTensor<double>> gen{};
    blaze::DynamicTensor<double> m = gen.generate(11UL, 17UL, 13UL);

    phylanx::execution_tree::primitive arg1 =
        phylanx::execution_tree::primitives::create_variable(
            hpx::find_here(), phylanx::ir::node_data<double>(m));

    phylanx::execution_tree::primitive size =
        phylanx::execution_tree::primitives::create_size_operation(
            hpx::find_here(),
            phylanx::execution_tree::primitive_arguments_type{
                std::move(arg1)});

    phylanx::execution_tree::primitive_argument_type f = size.eval().get();

    HPX_TEST_EQ(std::int64_t(2431),
        phylanx::execution_tree::extract_scalar_integer_value(f));
}

int main(int argc, char* argv[])
{
    test_extract_size_0d();
    test_extract_size_1d();
    test_extract_size_2d();
    test_extract_size_3d();

    return hpx::util::report_errors();
}
