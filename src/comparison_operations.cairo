use kakarot::context::ExecutionContext;
use kakarot::context::ExecutionContextTrait;
use kakarot::stack::Stack;
use kakarot::stack::StackTrait;

use option::OptionTrait;
use array::ArrayTrait;

#[derive(Drop, Copy)]
struct ComparisonOperations {}

const GAS_COST_ISZERO: felt = 3;

trait ComparisonOperationsTrait {
    fn new() -> ComparisonOperations;
    fn exec_iszero(ref context: ExecutionContext) -> ExecutionContext;
}

impl ComparisonOperationsImpl of ComparisonOperationsTrait {
    #[inline(always)]
    fn new() -> ComparisonOperations {
        ComparisonOperations {}
    }

    fn exec_iszero(ref context: ExecutionContext) -> ExecutionContext {
        let mut stack = context.stack;
        // 0 - offset: offset in the deployed code where execution will continue from
        // Option::<Array::<u8>>
        let mut element = stack.pop();
        match element {
            Option::Some(mut x) => {
                // Q: why stack result is an array? we asume that element 0 is the value to compare
                let option_result = x.get(0_usize);
                match option_result {
                    Option::Some(y) => {
                        let mut result_array = ArrayTrait::new();
                        if y == 0_u8 {
                            result_array.append(1_u8);
                        } else {
                            result_array.append(0_u8);
                        }
                        stack.push(result_array);
                    },
                    // Q: What happens if the content of the stack does not exist?
                    Option::None(_) => {
                        let mut data = ArrayTrait::new();
                        data.append('OOG');
                        panic(data);
                    }
                }
            },
            // Q: What happens if there is no element on the stack?
            Option::None(_) => {
                let mut data = ArrayTrait::new();
                data.append('OOG');
                panic(data);
            }
        }

        // TODO: update_stack not implemented
        // let ctx = ExecutionContext.update_stack(ref context, stack);
        // let ctx = ExecutionContext.increment_gas_used(ref context, GAS_COST_ISZERO);
        context.process_intrinsic_gas_cost();
        context
    }
}

impl ArrayU8Drop of Drop::<Array::<u8>>;
impl ArrayU8Copy of Copy::<Array::<u8>>;