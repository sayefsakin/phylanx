//  Copyright (c) 2017-2018 Hartmut Kaiser
//
//  Distributed under the Boost Software License, Version 1.0. (See accompanying
//  file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#if !defined(PHYLANX_PRIMITIVES_BLOCK_OPERATION_OCT_08_2017_0757PM)
#define PHYLANX_PRIMITIVES_BLOCK_OPERATION_OCT_08_2017_0757PM

#include <phylanx/config.hpp>
#include <phylanx/execution_tree/primitives/base_primitive.hpp>
#include <phylanx/execution_tree/primitives/primitive_component_base.hpp>
#include <phylanx/ir/node_data.hpp>

#include <hpx/lcos/future.hpp>

#include <cstddef>
#include <memory>
#include <string>
#include <vector>

namespace phylanx { namespace execution_tree { namespace primitives
{
    class block_operation
        : public primitive_component_base
        , public std::enable_shared_from_this<block_operation>
    {
    protected:
        hpx::future<primitive_argument_type> eval(
            std::vector<primitive_argument_type> const& operands,
            std::vector<primitive_argument_type> args) const;

    public:
        static match_pattern_type const match_data;

        block_operation() = default;

        block_operation(std::vector<primitive_argument_type>&& operands,
            std::string const& name, std::string const& codename);

        hpx::future<primitive_argument_type> eval(
            std::vector<primitive_argument_type> const& args) const override;

    private:
        void next(std::size_t i,
            std::vector<primitive_argument_type>&& args,
            hpx::lcos::local::promise<primitive_argument_type>&& result) const;
    };

    PHYLANX_EXPORT primitive create_block_operation(
        hpx::id_type const& locality,
        std::vector<primitive_argument_type>&& operands,
        std::string const& name = "", std::string const& codename = "");
}}}

#endif


