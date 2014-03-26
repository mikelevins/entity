# entity

Simple and extensible entities. An entity is a bundle of slots, where
a slot is key/value pair.

Many representations are possible for such an object; entity does not
specify any particular one. Instead, it defines an abstract entity
class and an interface of generic functions that can be specialized
for any suitable representation.

A simple default representation is provided, 'alist-entity. As its
name suggests, alist-entity represents an entity as an association
list.

## Reference

### Packages

entity [*Package*]
The package in which all entity types and procedures are defined.

### Special variables

*default-entity-class-name* [*Special variable*]
The name of the default class of entities instantiated by calling
entity constructors. You can assign or rebind a class name to this
variable in order to change the class of new entities created by the
constructors. Alternatively, you can explicitly pass class names to
the contructors to instantiate specific classes.

The default value of this variable is alist-entity.

### Classes

entity [*Class*]

The abstract superclass of all entity classes.

### Conditions

no-such-key [*Condition*]

A condition that signifies that an operation attempted to access a key
that was not present on an entity.

key-exists [*Condition*]

A condition that signifies that an operation attempted to add a key to
an entity that already contained the key.

### Generic functions

Functions that accept the key-test keyword argument use the procedure
passed in key-test to test whether a supplied key is the same as any
key found in entity. It should be a procedure of two arguments; the
first argument will be the supplied key; and the second will be each
key from entity that is being tested.

contains-key? entity key &key (key-test 'equal) => key, val Returns
two values. If `key` is present in the entity the first value returned
is the key and the second is the associated value. If the key is not
present in the entity then both returned values are nil.

get-key entity key &key (default nil) (key-test 'equal)

Returns the value in entity that is associated with key. If key is not
present in the entity then get-key returns default.

set-key! entity key val &key (key-test 'equal)

Updates the value in entity that is associated with key, replacing it
with val. set-key! updates the entity destructively, modifying its
structure. If key is not present in the entity then set-key! signals
an error of class no-such-key.

add-key entity key val &key key-test

Returns a new entity constructed by adding key to entity with the
value val. If entity already contains key then an error of class
key-exists is signaled.

add-key! entity key val &key key-test

Updates the structure of entity, adding key with the associated value
val. add-key! updates the entity destructively, modifying its
structure. If key is already present in the entity then add-key!
signals an error of class key-exists.

ensure-key entity key val &key key-test)

Returns an entity that contains key. If entity already contains key
then it is returned unchanged; otherwise a new entity is constructed
and returned, containing all of entity's keys, plus key, which is
associated with the value val.

ensure-key! entity key val &key key-test)

Returns entity, modified to contain key. If entity already contains
key then it is returned unchanged. Otherwise, key is added to entity,
modifying its structure, and val is associated with key. The modified
entity is then returned.

remove-key entity key &key key-test)

Returns an entity that does not contain key. If entity already does
not contain key then it is returned unchanged; otherwise a new entity
is constructed and returned, containing all of entity's keys, minus
key.

remove-key! entity key &key key-test

Returns entity, modified so it doesn't contain key. If entity already
doesn't contain key then it is returned unchanged. Otherwise, key is
removed from entity, modifying its structure. The modified entity is
then returned.

keys entity

Returns a list of all keys contained by entity.

vals entity

Returns a list of all values contained by entity (that is, all values associated with any key in entity).

map-keys procedure entity

map-keys maps procedure over the key/value pairs in entity. procedure
should be a function of two arguments, k and v; for each key/value
pair in entity, map-keys applies procedure, passing the key as the
first argument and the value as the second. It collects the result
values produced by each application of procedure in a list. Results
appear in the same order in the result list that the key/value pairs
were visited.

It is an error to modify the internal structure of entity during the
execution of map-keys.

merge-keys entity1 entity2 &key key-test resolve-collision

Returns a new entity that contains all the keys from both entity1 and
entity2.

If a key appears in both entity1 and entity2 then the procedure passed
as the value of :resolve-collision is used to decide which key and
value to use. The default resolve-collision always uses the key and
value from entity2.

resolve collision must be a function of the following form:

    (lambda (entity1 entity2 key1 key2) ...)

It must return two values: the key to be used in the merged entity and
the value to be used in the merged entity.


