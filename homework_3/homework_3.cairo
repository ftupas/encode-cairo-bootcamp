// Use the output builtin.
%builtins output

// Import the serialize_word() function.
from starkware.cairo.common.serialize import serialize_word

func square(x : felt) -> (x_squared : felt) {
    return (x_squared = x * x);
}

func main{output_ptr: felt*}() {
    tempvar x = 10;
    tempvar y = x + x;
    tempvar z = y * y + x;
    serialize_word(x);
    serialize_word(y);
    serialize_word(z);

    let (x_squared : felt) = square(x);
    serialize_word(x_squared);
    return ();
}
