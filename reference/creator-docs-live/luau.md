---
title: "Luau"
url: /docs/en-us/luau
last_updated: 2026-11-05T19:15:54Z
description: "Luau is the scripting language creators use in Roblox Studio."
---

# Luau

[Luau](https://luau.org) is the scripting language creators use in Roblox Studio. It is a fast, small, safe, gradually typed embeddable scripting language derived from [Lua 5.1](https://www.lua.org/manual/5.1/).

> **Success:** Contributing your Luau scripts for AI training can help enhance Luau-focused AI tools in Studio. For more information, see [Empower Luau creation](https://create.roblox.com/data-collection).
## Support in Studio

The **Script Editor** in Studio supports Luau with autocompletion, syntax highlighting, static linting, type checking, and script analysis. It also shows documentation and function signatures for members of the [Roblox Engine API](/docs/en-us/reference/engine.md).

## Types

Luau includes the following data types:

- [Nil](/docs/en-us/nil.md) represents non-existence or nothingness. It's different from any other value or data type.
- [Booleans](/docs/en-us/booleans.md), or `bool`, have a value of either `false` or `true`.
- [Numbers](/docs/en-us/numbers.md), or `double`, represent double-precision (64-bit) floating-point numbers.
- [Strings](/docs/en-us/strings.md) are sequences of characters, such as letters, numbers, and symbols.
- [Tables](/docs/en-us/tables.md) are [arrays](/docs/en-us/tables.md#arrays) or [dictionaries](/docs/en-us/tables.md#dictionaries) of any value except `nil`.
- [Enums](/docs/en-us/enums.md) are fixed lists of items.

Luau is dynamically typed by default. Variables, function parameters, and return values can be any data type. This helps you write code faster because you don't need to provide types for each piece of data. You can still declare explicit types for variables in Luau and enable [strict type checking](/docs/en-us/type-checking.md) to make type issues obvious and easy to locate.

## Data structures

You can also implement the following data structures using primitive data types:

- [Stacks](/docs/en-us/stacks.md) are Last-In-First-Out collections of items that you can implement using tables.
- [Queues](/docs/en-us/queues.md) are First-In-First-Out collections of items that you can implement using tables.
- [Metatables](/docs/en-us/metatables.md) are tables with advanced configurations that can achieve functionalities such as storing pairs of keys and values and calculating arithmetic operations.

## Features

In Luau, [variables](/docs/en-us/variables.md) and [functions](/docs/en-us/functions.md) can have global and local [scope](/docs/en-us/scope.md) within a script. Luau has logical, relational, and compound assignment [operators](/docs/en-us/operators.md). You can use [control structures](/docs/en-us/control-structures.md) and [functions](/docs/en-us/functions.md) to control when Luau executes code. Many operators and variable assignments perform [type coercion](/docs/en-us/type-coercion.md) to change values to the types that Luau expects.
</document>

<document url="/docs/en-us/luau/luau-csharp-comparison.md" title="Luau and C# comparison">
