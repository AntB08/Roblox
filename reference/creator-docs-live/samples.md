---
title: "Code samples"
url: /docs/en-us/samples
last_updated: 2026-11-05T19:16:05Z
description: "Use Code Samples as reference and learning tools for various Studio features."
---

# Code samples

The following samples show you how to carry out common scripting tasks in Roblox. Where applicable, corresponding 3D objects or models are provided. You can import the samples directly into your inventory where you can view them in the Studio **Toolbox** or open them directly in Studio.

#### Action Manager

Provides a wrapper for ContextActionService that displays actions on-screen. Input prompts automatically change based on the latest input type, rather than being set once based on peripherals.

#### Admin Commands

Demonstrates an admin command system using TextChatCommands. Command functions are stored in the Commands module and have an included permission level. Permission levels are determined from group rankings or a manual override set in the Admins module.

#### Beam Between

Given two attachments and a beam prefab, this class continuously orients duplicates of the attachments to face each other so that the beam remains straight. Also provides an API to enable/disable the beam and its orientation updates.

#### Change Part Color On Touch

Demonstrates changing the color of a part upon being touched by a player's character. The color change is debounced to ensure the Touched event does not trigger a color change too quickly. The part's color is randomly set using math.random.

#### Character Loaded Wrapper

Provides an API to use when referencing a Player's character to make sure it is "Fully loaded", which is defined as: 1) Character is a descendant of workspace 2) Character has a PrimaryPart set 3) Character contains a child which is a Humanoid 4) The Humanoid's RootPart property is not nil

#### Character Path Beam

Creates a guiding beam from the bottom of the local character to a destination attachment. Useful for guiding players towards objectives in order to progress.

#### Cloud Config

Demonstrates a cloud configuration system where flag values can be set in DataStore and are automatically polled for updates by live servers.

#### Code Reservation Service

Demonstrates a system to reserve and hand out single-use codes.

#### Create Instance Tree

Creates instances with given properties based on the given tree data table. This streamlines the tedious process of calling Instance.new and setting each property by creating a table of properties and a ClassName instead.

#### Crossfading Two Sounds

Crossfading is an audio editing technique that creates a smooth transition between two audio clips. Demonstrates crossfading between two sounds indefinitely.

#### Data Store Retries

DataStoreWrapper provides a retry mechanism for Data Stores that respects the order in which requests were made.

#### Donation Leaderboard

An example of a simple donation leaderboard. DevProducts IDs can be placed in the DonationProducts ModuleScript and will be displayed on the leaderboard to purchase. Upon purchase, the player's donation amount is incremented based on how many robux were spent.

#### Find First Child With Attribute

Searches children of an instance, returning the first child containing an attribute matching the given name and value. The DemoScript removes flavors from an ice cream cone in the correct order using findFirstChildWithAttribute

#### Raycasting

The fireRaycast function fires a ray from an Attachment position, visualizing the path of the ray and the surface normal that was hit. A model named "Device" rotates around in a circle, pointing the ray at various objects.

#### Model Following a Player

The FollowingAttachment module creates an attachment that trails on the ground at some max distance behind a player's character. DemoScript uses constraints to align a rock part's position and orientation with the attachment such that the rock follows each player's character. The attachment stops updating and the rock is destroyed when the character dies.

#### Format Time

Formats a number of seconds into a pretty string of Hours, Minutes, and Seconds. If all hours are 0, they are omitted. If all hours and all minutes are 0, they are both omitted. Leading 0's from hours are removed. If hours are omitted, leading 0's from minutes are removed. If hours and minutes are omitted, leading 0's from seconds are removed. The DemoScript uses formatTime to display a timer that rapidly increases on a Part.

#### Geofencing

Demonstrates a geofencing system to block content from users based on their region.

#### Get Character Attachment

Returns the attachment corresponding with AttachmentName under the character. The DemoScript uses getCharacterAttachment to correctly attach a pizza slice to a character's RightGripAttachment.

#### Input Categorizer

The InputCategorizer module categorizes various UserInputTypes (MouseButton1, MouseButton2, Gamepad1/2/3, etc.) into more manageable categories and provides an event for when the last input category changes, rather than last UserInputType.

#### Isometric Camera

Demonstrates how to update a player's camera to create an Isometric Camera style. The camera updates every render step to ensure the camera maintains a constant distance from the player, as well as follows the player as they move.

#### Leader Election

Demonstrates how to run a loop on a single server at once using MemoryStores. Useful for things like global matchmaking code that only need to run on one server at a time.

#### Lighting Presets

Demonstrates a system for storing lighting presets and updating the lighting settings from those presets. Presets can be set directly or tweened between to create e.g. a day/night cycle.

#### Playing an Animation

The loadAnimationTrack function is used to load an animation on an Animator by providing an animation asset ID.

#### Loading Screen

Demonstrates an example of a loading screen. The `updateDetailText` function provides the ability to update text on the loading screen with information on what is happening behind the scenes. A spinner gives the user confidence that the game is still running. Note: the sample must be placed within ReplicatedFirst to work properly.

#### Moderation System

Demonstrates a simple moderation system that can kick users from any server or ban them for arbitrary lengths of time.

#### Play Smoke Puff

Plays a particle animation of a puff of smoke at the location, volume, and size of a given part.

#### Player Lifecycle Events

Demonstrates connecting to common player, character and humanoid events. Events covered: PlayerAdded, PlayerRemoving, CharacterAdded, CharacterRemoving, CharacterAppearanceLoaded and Died (humanoid).

#### Portal Door

Demonstrates a portal door system that allows a player to walk into a small exterior building and appear inside a larger interior.

#### Retry Async

`retryAsync` retries function calls that may fail, and provides various arguments to describe the retry behavior. The first argument is the function it calls repeatedly until it either succeeds or is called the maximum number of times specified by `maxAttempts`. The optional third and fourth arguments allow you to customize the initial pause time and the exponent used to increase the pause time with each retry. The optional fifth argument allows you to specify a function call handler, used to make each function call (default is pcall). `retryAsync` returns a boolean indicating whether the final call to the given function was successful, and the return values of the final call (if successful) or the error message (if not successful). DemoScript provides an example using retryAsync to call a function that intentionally has a chance to error. Results of each call and the final result are printed.

#### Safe Player Added

Calls the given callback for all existing players in the game, and any that join thereafter. Useful in situations where you want to run code for every player, even players who are already in the game. The DemoScript uses safePlayerAdded to ensure all players in the game have a billboard with their name above their character's heads.

#### Custom Event

Signal is a custom event that works as a replacement for BindableEvents to create custom events and replicates the behavior of RBXScriptSignal. Objects are passed by reference, which is not possible with BindableEvents.

#### Sprint with Button

Demonstrates how to increase a player's speed when specific inputs are pressed. This sample implements left shift to run on keyboard, X to run on gamepad, and a touch button for mobile. The input buttons can be modified to any input desired.

#### ThreadQueue

ThreadQueue can be used to queue functions so that they don't all run at once. In this example, 10 functions are added to a queue at the same time, and then executed in order with a 1s delay between them.

#### Toggling Gui Frames

Demonstrates how to show and hide different frames within a Gui. The example starts with a menu button visible to the player. When pressed, the menu button is hidden and a menu window appears. Clicking the 'X' at the top right corner of the menu will bring the user back to the original view.

#### Tween Group

Links a group of tweens together, allowing them to be played, paused and cancelled as one. Note: TweenGroup does not support PlaybackState or Completed events.

#### Using TweenService on a Model

Demonstrates how to properly tween a model. Models should be tweened from an anchored part. If parts within the model are unanchored, weld these parts to the anchored part. Otherwise the unanchored parts will not follow the model as it tweens. In this case, the Base part is set as the HealthPack's PrimaryPart and all other parts in the model are welded to it.

#### Parallax Portal

Demonstrates a portal with a 'depth' effect achieved with parallaxing images.

#### Leaderboard Module

The Leaderboard Module updates a player's leaderboard with a name (statName) and value. The module creates the initial leaderboard as well as the stat for the player if it does not already exist. The demo used the Leaderboard Module to update all player's leaderboards with a "Points" stat that increases over time.

#### Purchase Handling

This sample demonstrates an approach to safely and robustly awarding developer product purchases to players

#### Player Data

This sample demonstrates an approach to storing and accessing player data
</document>

<document url="/docs/en-us/scale.md" title="Reach a massive global audience">
