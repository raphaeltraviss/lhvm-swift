#  NumberForth implementation

## Compute functions
// Our computation functions all return a Double value.  But how do they compute
// this value?  First, they look for operands on the "stack" (the "compute stack"
// shown in the UI).  Some of these operands need to reference state saved on the
// "state_stack" (for example, MULTIPLEX needs to set a bit).  I'm not sure if this
// is better-implemented as an array of values, or as a nested Computation stack.


Another consequence of this, is that the same function can consume variable
numbers of computations... which might be useful for doing a 3-way ADD, or for
MULTIPLEX.


## Compute functions with state listeners: stateful compute functions

MULTIPLEX can be implemented as a N-ary computation that records the ops it gets until
it hits BEGIN, generates a function based on this stack, and then runs that
function, with values passed in, on the state_stack.

### Implementation 1: recursive listener function

In order to work, MULTIPLEX creates its own recursive function, that consumes
computations on the stack, gathering them on a closure, stopping as soon as it sees
BEGIN, and then returning the new (partially-consumed) stack, along with the resultant
function, which it runs according to the arguments MULTIPLEX was passed on the stack.
This recursive function is NOT a compute function, because it contains a listener that
just returns a comput function after it hits the BEGIN nullary.

Technically, stateful compute functions are pure, because they will always generate the same
output, given the same compute stack as input.  Even though "stateful compute functions"
add state to the stack, this state is handled entirely within the function itself, via the mini-
recursive functions they use internally to do this.

#### Implementation 2: just slice the stack

Since we are entering items in RPN order, all you have to do is, when you encounter a MULTIPLEX,
start slicing items off the stack until you hit BEGIN, and then pass the whole thing into the
MULTIPLEX function implementation.

The problem with this method, is that if you had already designged a function that you wanted to
multiplex, you'd have to go back and insert BEGIN before it.

#### Implementation 3: just multiplex the next recursively-built computation function on the stack

This way, you don't have to enter BEGIN and other control-flow keywords.

You would, however, have to make BIND keywords within the function body, and then tell MULTIPLEX
 to bind to these variables in its arguments.  So, it's kind of the same as BEGIN, but a little bit more
 explicit.
 
 ### Maybe we can use both?
 
 MULTIPLEX takes one argument from the stack, but internally, create a recursive listener function that
 accepts its particular type of state, and then binds it to a dictionary symbol.  Inside of the Compute function,
 the BIND op looks for this symbol, and substitues the value when it finds it?
 
 **Otherwise, variables like BIND can just be ignored.**  However, they still set an internal dictionary of
 symbols... in this case, doing BIND on a double value, is actually BINDing that variable name to a function
 that returns a Double.
 
 In essence, BIND creates an internal dictionary, that's only used within the implementation of things like
 MULTIPLEX and such.  This internal dictionary exists only within the ops that use it (like MULTIPLEX), and
 it is created separately, within each stateful op.  The reason for this, is that we do not want BIND symbols
 to be global and affect each other: you would have an "index" variable bound at one point in the stack,
 and another "index" variable bound at another point in the stack, and they would both work, because
 they are bound inside of different scopes.
 
 Another name for a **stateful computation** would be a **scoped computation**.
 
 The downside is that we need to create special syntax, to map MULTIPLEX's index and multiplexed
 value to the variables encountered when evaluating its function argument.

## Not all compute functions are pure

**Receptor functions** usually are nullary functions that consult SCHEMA_STATE and
ENVIRONMENT_STATE objects, and return a certain Double value that you are interested
in, such as Mouse X or Mouse Y.

After the native function is generated, the functions still need to reference these objects at
every sample frame, in order to provide their values.

If the native function is instead being output to Metal or OpelGL to run on the GPU, then these
state objects will be converted into buffers, so the shader code can access them.


# Up next: how do we implement variables?
I think I've got variables figured out with the whole "scoped computation" deal, but we still don't know
how we want our syntax to look for the following features:
* how does MULTIPLEX know to bind its index and value internal state to the variable names within
  its input computation stack?  (how do we enter variable references on the stack)?
* how does MULTIPLEX know how many times to loop, what value to start at, and how to mutate
  that value every iteration? (how do we do FOR/WHILE/UNTIL loops on the stack)?
  
  Right now, MULTIPLEX is simply a function that produces a Double value, but we might need to make
  it a special syntax or keyword, to accomplish the above syntax.  We might need to introduce BEGIN
  syntax, or some other shite.
