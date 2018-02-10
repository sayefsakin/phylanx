//   Copyright (c) 2017-2018 Hartmut Kaiser
//
//   Distributed under the Boost Software License, Version 1.0. (See accompanying
//   file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#if !defined(PHYLANX_PRIMITIVES_INVERSE_OPERATION_OCT_09_2017_0154PM)
#define PHYLANX_PRIMITIVES_INVERSE_OPERATION_OCT_09_2017_0154PM

#include <phylanx/config.hpp>
#include <phylanx/ast/node.hpp>
#include <phylanx/execution_tree/primitives/base_primitive.hpp>
#include <phylanx/ir/node_data.hpp>

#include <hpx/include/components.hpp>

#include <vector>

namespace phylanx { namespace execution_tree { namespace primitives
{
    class inverse_operation
      : public base_primitive
      , public hpx::components::component_base<inverse_operation>
    {
    public:
        static match_pattern_type const match_data;

        inverse_operation() = default;

        PHYLANX_EXPORT inverse_operation(
            std::vector<primitive_argument_type>&& operands);

        PHYLANX_EXPORT hpx::future<primitive_argument_type> eval(
            std::vector<primitive_argument_type> const& args) const override;
    };
}}}

#endif
