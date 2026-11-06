# Deprecated Roblox Engine APIs

> **For LLM code assistants:** Do NOT suggest any API listed below. If you encounter these in existing code, suggest the replacement and help the user migrate.

Total deprecated members: **603**

Last generated from YAML source at build time.

## Deprecated Properties (141)

| Class/Type | Member | Replacement | Note |
|------------|--------|-------------|------|
| AccessoryDescription | `Puffiness` | *(none)* | Deprecated. |
| AnalyticsService | `ApiKey` | *(see note)* | This property is deprecated. Do not use it for new work. |
| Attachment | `Rotation` | `Orientation` | This property is deprecated and should not be used in new work. See Orientation instead. |
| Attachment | `WorldRotation` | `WorldOrientation` | This item has been superseded by WorldOrientation which should be used in new work. |
| AudioEmitter | `SimulationFidelity` | *(none)* | Deprecated. |
| AudioListener | `SimulationFidelity` | *(none)* | Deprecated. |
| AudioPlayer | `AssetId` | `Asset` | This property is deprecated; use Asset instead. |
| AudioSearchParams | `AudioSubtype` | `AudioSubType` | Use AudioSubType instead. |
| BasePart | `BackParamA` | *(none)* | Deprecated. |
| BasePart | `BackParamB` | *(none)* | Deprecated. |
| BasePart | `BackSurfaceInput` | *(none)* | Deprecated. |
| BasePart | `BottomParamA` | *(none)* | Deprecated. |
| BasePart | `BottomParamB` | *(none)* | Deprecated. |
| BasePart | `BottomSurfaceInput` | *(none)* | Deprecated. |
| BasePart | `brickColor` | *(see note)* | This deprecated property is an old Camel Case variant of the Pascal Case BasePart.BrickColor, which should be used inste |
| BasePart | `CollisionGroupId` | *(none)* | Deprecated. |
| BasePart | `Elasticity` | *(see note)* | This is only one of multiple physics-related properties. It has been deprecated in favor of BasePart.CustomPhysicalPrope |
| BasePart | `Friction` | *(see note)* | This is only one of multiple physics-related properties. It has been deprecated in favor of BasePart.CustomPhysicalPrope |
| BasePart | `FrontParamA` | *(none)* | Deprecated. |
| BasePart | `FrontParamB` | *(none)* | Deprecated. |
| BasePart | `FrontSurfaceInput` | *(none)* | Deprecated. |
| BasePart | `LeftParamA` | *(none)* | Deprecated. |
| BasePart | `LeftParamB` | *(none)* | Deprecated. |
| BasePart | `LeftSurfaceInput` | *(none)* | Deprecated. |
| BasePart | `RightParamA` | *(none)* | Deprecated. |
| BasePart | `RightParamB` | *(none)* | Deprecated. |
| BasePart | `RightSurfaceInput` | *(none)* | Deprecated. |
| BasePart | `RotVelocity` | `AssemblyAngularVelocity` | This property is deprecated. Use `AssemblyAngularVelocity` instead. |
| BasePart | `SpecificGravity` | `BasePart.CustomPhysicalProperties` | This item is deprecated. See BasePart.CustomPhysicalProperties to see how to configure the physical properties of BasePa |
| BasePart | `TopParamA` | *(none)* | Deprecated. |
| BasePart | `TopParamB` | *(none)* | Deprecated. |
| BasePart | `TopSurfaceInput` | *(none)* | Deprecated. |
| BasePart | `Velocity` | `AssemblyLinearVelocity` | This property is deprecated. Use `AssemblyLinearVelocity` instead. |
| BaseScript | `LinkedSource` | *(see note)* | This property is now replaced by [packages](../../../projects/assets/packages.md) which has greater functionality. |
| BillboardGui | `DistanceLowerLimit` | *(none)* | Deprecated. |
| BillboardGui | `DistanceUpperLimit` | *(none)* | Deprecated. |
| BodyAngularVelocity | `angularvelocity` | *(see note)* | This deprecated property is a variant of BodyAngularVelocity.AngularVelocity which should be used instead. |
| BodyAngularVelocity | `maxTorque` | *(see note)* | This deprecated property is a variant of BodyAngularVelocity.MaxTorque which should be used instead. |
| BodyForce | `force` | *(see note)* | This deprecated property is a variant of BodyForce.Force which should be used instead. |
| BodyGyro | `cframe` | *(see note)* | This property is a deprecated variant of BodyGyro.CFrame which should be used instead. |
| BodyGyro | `maxTorque` | *(see note)* | This property is a deprecated variant of BodyGyro.MaxTorque which should be used instead. |
| BodyPosition | `maxForce` | *(see note)* | This property is a deprecated variant of BodyPosition.MaxForce which should be used instead. |
| BodyPosition | `position` | *(see note)* | This is a deprecated variant of BodyPosition.Position which should be used instead. |
| BodyThrust | `force` | *(see note)* | This property is a deprecated variant of Force which should be used instead. |
| BodyThrust | `location` | *(see note)* | This property is a deprecated variant of BodyThrust.Location which should be used instead. |
| BodyVelocity | `maxForce` | *(see note)* | This property is a deprecated variant of BodyVelocity.MaxForce which should be used instead. |
| BodyVelocity | `velocity` | *(see note)* | This property is a deprecated variant of BodyVelocity.Velocity which should be used instead. |
| Camera | `CoordinateFrame` | `Camera.CFrame` | This item has been superseded by Camera.CFrame which should be used in all new work. |
| Camera | `focus` | *(see note)* | This property is a deprecated variant of Focus which should be used instead. |
| CylindricalConstraint | `SoftlockAngularServoUponReachingTarget` | *(see note)* | This property should not be used in new work. |
| DataModel | `GearGenreSetting` | *(see note)* | This property is deprecated and is no longer functional. It should not be used. |
| DataModel | `lighting` | `game:GetService` | This item has been superseded by game:GetService("Lighting"), which should be used instead. |
| DataModel | `VIPServerId` | `DataModel.PrivateServerId` | This property has been deprecated. Use DataModel.PrivateServerId instead. |
| DataModel | `VIPServerOwnerId` | `DataModel.PrivateServerOwnerId` | This property has been deprecated. Use DataModel.PrivateServerOwnerId instead. |
| DataModel | `workspace` | *(see note)* | This deprecated property is a variant of DataModel.Workspace which should be used instead. |
| Debris | `MaxItems` | *(see note)* | This property is deprecated and should not be used in new work. |
| Decal | `Shiny` | *(see note)* | This non-functional property is deprecated and should not be used in new work. |
| Decal | `Specular` | *(see note)* | This property no longer functions correctly and is deprecated. It should not be used in new work. |
| Fire | `size` | *(see note)* | This property is a deprecated variant of Fire.Size which should be used instead. |
| FormFactorPart | `formFactor` | *(see note)* | This property has been deprecated and should not be used in new work. |
| FormFactorPart | `FormFactor` | *(see note)* | This property has been deprecated and should not be used in new work. |
| GameSettings | `VideoCaptureEnabled` | *(see note)* | This property is deprecated. Do not use it for new work. |
| GuiBase2d | `Localize` | *(see note)* | This item is deprecated. Do not use it for new work. |
| GuiBase3d | `Color` | *(see note)* | This property has been deprecated in favor of GuiBase3d.Color3, which allows for greater color customization and should  |
| GuiObject | `BackgroundColor` | *(see note)* | This property is deprecated in favor of the Color3 property GuiObject.BackgroundColor3, which should be used in new work |
| GuiObject | `BorderColor` | *(see note)* | This property is deprecated in favor of the Color3 property BorderColor3, which should be used in new work instead. |
| GuiObject | `Draggable` | `UIDragDetector` | This property is deprecated. Use UIDragDetector instead, as it supports more input types and can be better customized. |
| GuiObject | `Transparency` | *(see note)* | This property is deprecated and indexing it will return BackgroundTransparency. |
| GuiService | `IsModalDialog` | *(see note)* | This item is deprecated. Do not use it for new work. |
| GuiService | `IsWindows` | *(see note)* | This item is deprecated. Do not use it for new work. |
| HingeConstraint | `SoftlockServoUponReachingTarget` | *(see note)* | This property should not be used in new work. |
| Humanoid | `CollisionType` | *(none)* | Deprecated. |
| Humanoid | `LeftLeg` | *(see note)* | This instance only works with the old R6 rig. It will not work with the R15 rig and should not be used in new work not u |
| Humanoid | `maxHealth` | *(see note)* | This deprecated property is a variant of Humanoid.MaxHealth which should be used instead. |
| Humanoid | `RightLeg` | *(see note)* | This instance only works with the old R6 rig. It will not work with the R15 rig and should not be used in new work not u |
| Humanoid | `Torso` | *(see note)* | This instance only works with the old R6 rig. It will not work with the R15 rig and should not be used in new work not u |
| InsertService | `AllowInsertFreeModels` | *(see note)* | This item was never released. Do not use it in new work. |
| Instance | `archivable` | *(see note)* | This deprecated property is a variant of Instance.Archivable which should be used instead. |
| JointInstance | `part1` | *(see note)* | This deprecated property is a variant of Part1 which should be used instead. |
| Lighting | `Outlines` | *(see note)* | This item is no longer supported as the outlines feature was removed from the Roblox platform. |
| Lighting | `ShadowColor` | *(see note)* | This item is deprecated and has no current functionality. Do not use it for new work. |
| Lighting | `Technology` | `LightingStyle` | This property has been superseded by LightingStyle which determines the artistic intent behind lighting, and PrioritizeL |
| LocalizationTable | `DevelopmentLanguage` | `LocalizationTable.SourceLocaleId` | This item has been superseded by LocalizationTable.SourceLocaleId which should be used in all new work. |
| LocalizationTable | `Root` | *(see note)* | This item is deprecated. Do not use it for new work. |
| MeshPart | `HasJointOffset` | *(see note)* | This property is deprecated and should not be used in new work. |
| MeshPart | `JointOffset` | *(see note)* | This property is deprecated and should not be used in new work. |
| ModuleScript | `LinkedSource` | *(see note)* | This property is now replaced by [packages](../../../projects/assets/packages.md) which has greater functionality. |
| Mouse | `hit` | *(see note)* | This property is a deprecated variant of Mouse.Hit which should be used instead. |
| Mouse | `target` | *(see note)* | This property is a deprecated variant of Mouse.Target which should be used instead. |
| Object | `className` | *(see note)* | This deprecated property is a variant of Object.ClassName which should be used instead. |
| ParticleEmitter | `VelocitySpread` | `ParticleEmitter.SpreadAngle` | This property has been superseded by ParticleEmitter.SpreadAngle which should be used in all new work. |
| PathfindingService | `EmptyCutoff` | *(see note)* | This property is deprecated, since the legacy pathfinding system using it has since been removed. Do not use it for new  |
| Player | `CharacterAppearance` | *(see note)* | This item is deprecated. Do not use it for new work. |
| Player | `DataComplexity` | *(see note)* | This item is deprecated, as it may have been used for a now obsolete data persistence method. Please save and load playe |
| Player | `DataReady` | *(see note)* | This item is deprecated, as it may have been used for a now obsolete data persistence method. Please save and load playe |
| Player | `userId` | *(see note)* | This property is a deprecated variant of Player.UserId which should be used instead. |
| Players | `localPlayer` | *(see note)* | This property is a deprecated variant of Players.LocalPlayer which should be used instead. |
| Players | `numPlayers` | *(see note)* | This property is a deprecated variant of Players.NumPlayers which has also been deprecated. Neither property should be u |
| Players | `NumPlayers` | *(see note)* | This item is deprecated. Instead, of using this item, you should count the number of players returned by Players:GetPlay |
| Pose | `MaskWeight` | *(see note)* | This property is deprecated. Use the AnimationTrack:AdjustWeight() function when blending multiple animations. |
| ScreenshotHud | `ExperienceNameOverlayEnabled` | *(see note)* | This property is deprecated. Do not use it for new work. |
| ScreenshotHud | `OverlayFont` | *(see note)* | This property is deprecated. Do not use it for new work. |
| ScreenshotHud | `UsernameOverlayEnabled` | *(see note)* | This property is deprecated. Do not use it for new work. |
| SelectionBox | `SurfaceColor` | *(see note)* | This property is deprecated in favor of SurfaceColor3 which uses the more precise Color3 data type instead of a BrickCol |
| SelectionSphere | `SurfaceColor` | *(see note)* | This property is deprecated in favor of SurfaceColor3 which uses the more precise Color3 data type instead of a BrickCol |
| SlidingBallConstraint | `SoftlockServoUponReachingTarget` | *(see note)* | This property should not be used in new work. |
| Sound | `EmitterSize` | *(see note)* | This property has deprecated in favor of Sound.RollOffMinDistance and Sound.RollOffMaxDistance which should be used inst |
| Sound | `isPlaying` | *(see note)* | This deprecated property is a variant of Sound.IsPlaying which should be used instead. |
| Sound | `MaxDistance` | *(see note)* | This property has deprecated in favor of Sound.RollOffMinDistance and Sound.RollOffMaxDistance which should be used inst |
| Sound | `MinDistance` | `Sound.EmitterSize` | MinDistance has been superseded by Sound.EmitterSize, whose name better describes this properties behavior. |
| Sound | `Pitch` | *(see note)* | This property has been deprecated in favor of Sound.PlaybackSpeed whose name suits the behavior better. |
| StarterGui | `ResetPlayerGuiOnSpawn` | `LayerCollector.ResetOnSpawn` | This property is deprecated. Use LayerCollector.ResetOnSpawn to control the resetting behavior for individual LayerColle |
| Stats | `HeartbeatTimeMs` | `Stats.HeartbeatTime` | Use Stats.HeartbeatTime instead. |
| Stats | `PhysicsStepTimeMs` | `Stats.PhysicsStepTime` | Use Stats.PhysicsStepTime instead. |
| Studio | `UI Theme` | *(none)* | Deprecated. |
| StudioService | `DrawConstraintsOnTop` | *(see note)* | This property is deprecated; constraints can no longer be drawn "on top" of other objects. |
| Team | `AutoColorCharacters` | *(see note)* | This property is deprecated and no longer functions, it should not be used for new work. |
| Team | `Score` | *(see note)* | This property is deprecated and should not be used in new work. For more information on how to handle leaderboards and s |
| TeleportOptions | `ReservedServerAccessCode` | `TeleportOptions.ReservedServerId` | Use TeleportOptions.ReservedServerId with a developer-generated GUID and TeleportService:TeleportAsync() instead. For VI |
| TeleportOptions | `ShouldReserveServer` | `TeleportOptions.ReservedServerId` | Use TeleportOptions.ReservedServerId with a developer-generated GUID and TeleportService:TeleportAsync() instead. |
| TeleportService | `CustomizedTeleportUI` | *(see note)* | This item is deprecated since the default message it controls has been removed. Do not use it for new work. |
| Terrain | `IsSmooth` | *(see note)* | The legacy terrain engine has been removed, so this property will always be `true`. |
| TerrainRegion | `IsSmooth` | *(see note)* | This item is a deprecated function of a legacy Terrain engine that has been removed. Do not use it for new work. |
| TestService | `Is30FpsThrottleEnabled` | *(see note)* | This has been deprecated and directly renamed to ThrottlePhysicsToRealtime to better reflect its practical use. |
| TextBox | `FontSize` | `TextBox.TextSize` | This item has been superseded by TextBox.TextSize which should be used in all new work. |
| TextBox | `TextColor` | `TextBox.TextColor3` | This item has been superseded by TextBox.TextColor3 which should be used in all new work. |
| TextBox | `TextWrap` | `TextBox.TextWrapped` | This item has been superseded by TextBox.TextWrapped which should be used in all new work. |
| TextButton | `FontSize` | *(see note)* | This property is deprecated in favor of TextSize which is an integer and not an enum and thus offers far more options fo |
| TextButton | `TextColor` | `TextButton.TextColor3` | This item has been superseded by TextButton.TextColor3 which should be used in all new work. |
| TextButton | `TextWrap` | `TextButton.TextWrapped` | This item has been superseded by TextButton.TextWrapped which should be used in all new work. |
| TextLabel | `FontSize` | *(see note)* | This property is deprecated in favor of TextSize which is an integer and not an enum and thus offers far more options fo |
| TextLabel | `TextColor` | `TextLabel.TextColor3` | This item has been superseded by TextLabel.TextColor3 which should be used in all new work. |
| TextLabel | `TextWrap` | *(see note)* | This property is simply an alias for TextWrapped. Use the past-tense version instead. |
| TorsionSpringConstraint | `LimitEnabled` | `LimitsEnabled` | This property is deprecated. Use LimitsEnabled instead. |
| UserInputService | `ModalEnabled` | `GuiService.TouchControlsEnabled` | This item has been superseded by GuiService.TouchControlsEnabled which should be used in all new work. |
| UserInputService | `UserHeadCFrame` | `UserInputService:GetUserCFrame()` | This item has been superseded by UserInputService:GetUserCFrame() which should be used in all new work. |
| Workspace | `FilteringEnabled` | *(see note)* | This property is discontinued. |
| Workspace | `InterpolationThrottling` | *(see note)* | This property should not be used for new work. |
| WrapLayer | `Puffiness` | *(none)* | Deprecated. |
| WrapLayer | `ShrinkFactor` | *(none)* | Deprecated. |
| WrapTarget | `Stiffness` | *(none)* | Deprecated. |

## Deprecated Methods (247)

| Class/Type | Member | Replacement | Note |
|------------|--------|-------------|------|
| AdService | `ShowVideoAd` | *(see note)* | ShowVideoAd has been decommissioned and is no longer operational. |
| AnalyticsService | `FireCustomEvent` | *(see note)* | This deprecated function is a variant of AnalyticsService:LogCustomEvent() which should be used instead. |
| AnalyticsService | `FireEvent` | *(see note)* | This function has been deprecated in favor of more descriptive methods, including AnalyticsService:LogCustomEvent(), Ana |
| AnalyticsService | `FireInGameEconomyEvent` | *(see note)* | This deprecated function is a variant of AnalyticsService:LogEconomyEvent() which should be used instead. |
| AnalyticsService | `FireLogEvent` | *(see note)* | This method is deprecated. Do not use it for new work. |
| AnalyticsService | `FirePlayerProgressionEvent` | *(see note)* | This deprecated function is a variant of AnalyticsService:LogProgressionEvent() which should be used instead. |
| AnimationClipProvider | `GetAnimationClip` | `GetAnimationClipAsync` | This function is deprecated and can lead to the game freezing until the animation is loaded. Developers are recommended  |
| AnimationClipProvider | `GetAnimationClipById` | `GetAnimationClipAsync` | This function is deprecated and can lead to the game freezing until the animation is loaded. Developers are recommended  |
| AnimationClipProvider | `GetAnimations` | *(none)* | Deprecated. |
| AnimationController | `GetPlayingAnimationTracks` | *(none)* | Deprecated. |
| AnimationController | `LoadAnimation` | *(see note)* | This function is deprecated in favor of using Animator:LoadAnimation() directly (the Animator may be created while editi |
| AssetService | `GetAssetIdsForPackage` | `GetAssetIdsForPackageAsync` | Use GetAssetIdsForPackageAsync() instead. |
| AssetService | `GetCreatorAssetID` | *(see note)* | This item is deprecated and no longer functions correctly. Do not use it for new work. |
| AssetService | `SearchAudio` | `SearchAudioAsync` | Use SearchAudioAsync() instead. |
| Attachment | `GetAxis` | *(see note)* | This method is deprecated and should not be used in new work. |
| Attachment | `GetSecondaryAxis` | *(see note)* | This method is deprecated and should not be used in new work. |
| Attachment | `SetAxis` | *(see note)* | This method is deprecated and should not be used in new work. |
| Attachment | `SetSecondaryAxis` | *(see note)* | This method is deprecated and should not be used in new work. |
| AvatarEditorService | `CheckApplyDefaultClothing` | *(none)* | Deprecated. |
| AvatarEditorService | `ConformToAvatarRules` | *(none)* | Deprecated. |
| AvatarEditorService | `GetAvatarRules` | *(none)* | Deprecated. |
| AvatarEditorService | `GetBatchItemDetails` | *(none)* | Deprecated. |
| AvatarEditorService | `GetFavorite` | *(none)* | Deprecated. |
| AvatarEditorService | `GetInventory` | *(none)* | Deprecated. |
| AvatarEditorService | `GetItemDetails` | *(none)* | Deprecated. |
| AvatarEditorService | `GetOutfitDetails` | *(none)* | Deprecated. |
| AvatarEditorService | `GetOutfits` | *(none)* | Deprecated. |
| AvatarEditorService | `GetRecommendedAssets` | *(none)* | Deprecated. |
| AvatarEditorService | `GetRecommendedBundles` | *(none)* | Deprecated. |
| AvatarEditorService | `SearchCatalog` | *(none)* | Deprecated. |
| BadgeService | `AwardBadge` | `AwardBadgeAsync` | Use AwardBadgeAsync() instead. |
| BadgeService | `IsDisabled` | *(see note)* | This function is deprecated. Do not use it for new work. Instead, it can be checked by calling BadgeService:GetBadgeInfo |
| BadgeService | `IsLegal` | *(see note)* | This function is deprecated and will always return true. Do not use it for new work. |
| BadgeService | `UserHasBadge` | `BadgeService:UserHasBadgeAsync()` | This method has been superseded by BadgeService:UserHasBadgeAsync() which should be used for new work instead. |
| BasePart | `breakJoints` | *(see note)* | This deprecated function is a variant of BasePart:BreakJoints() which should be used instead. |
| BasePart | `BreakJoints` | *(see note)* | This method is deprecated. To break specific joints, iterate over the part's connections using BasePart:GetJoints() and  |
| BasePart | `getMass` | *(see note)* | This Camel Case property has been deprecated in favor of its Pascal Case variant, BasePart:GetMass(). |
| BasePart | `GetRenderCFrame` | *(see note)* | This item is been deprecated since interpolation is now applied to the CFrame directly. Do not use it for new work. |
| BasePart | `GetRootPart` | *(none)* | Deprecated. |
| BasePart | `makeJoints` | *(see note)* | This deprecated function is a variant of BasePart:MakeJoints() which should be used instead. |
| BasePart | `MakeJoints` | `MakeJoints` | SurfaceType based joining is deprecated, do not use MakeJoints for new projects. WeldConstraints and HingeConstraints sh |
| BasePart | `resize` | *(see note)* | This deprecated function is a variant of BasePart:Resize() which should be used instead. |
| BodyPosition | `lastForce` | `BodyPosition:GetLastForce()` | This property has been superseded by BodyPosition:GetLastForce() which should be used in new work instead, |
| Camera | `GetLargestCutoffDistance` | *(see note)* | This method is deprecated. Do not use it for new work. |
| Camera | `GetPanSpeed` | *(see note)* | This method has been deprecated and no longer works. It should not be used in new work. |
| Camera | `GetTiltSpeed` | *(see note)* | This method has been deprecated and no longer works. |
| Camera | `Interpolate` | `TweenService` | This method has been deprecated. Instead use TweenService to smoothly animate the Camera, see the code snippets below fo |
| Camera | `PanUnits` | *(see note)* | This method was used for legacy camera controls and has since been deprecated. Do not use in new work. |
| Camera | `SetCameraPanMode` | *(see note)* | This method has been deprecated and should not be used in new work. |
| Camera | `TiltUnits` | *(see note)* | This method was used for legacy camera controls and has been deprecated. Do not use in new work. |
| Chat | `FilterStringForPlayerAsync` | `Chat:FilterStringAsync()` | This item has been superseded by Chat:FilterStringAsync() and Chat:FilterStringForBroadcast() which should be used in al |
| CollectionService | `GetCollection` | *(see note)* | This item has been superseded by a CollectionService tagging method. The equivalent function using the new method is Col |
| Constraint | `GetDebugAppliedForce` | *(see note)* | This method should not be used in new work. |
| Constraint | `GetDebugAppliedTorque` | *(see note)* | This method should not be used in new work. |
| ContentProvider | `Preload` | `ContentProvider:PreloadAsync()` | This item has been superseded by ContentProvider:PreloadAsync() which should be used in all new work. |
| ContextActionService | `BindActionToInputTypes` | `ContextActionService:BindAction()` | This item has been superseded by ContextActionService:BindAction() which should be used in all new work. |
| Controller | `bindButton` | *(see note)* | This function is a deprecated variant of Controller:BindButton() which should be used instead. |
| Controller | `getButton` | *(see note)* | This function is a deprecated variant of Controller:GetButton() which should be used instead. |
| DataModel | `GetMessage` | *(see note)* | This item is deprecated since the system was phased out a very long time ago, and recently the APIs for setting this mes |
| DataModel | `GetRemoteBuildMode` | `RunService:IsServer()` | This item is deprecated. Use RunService:IsServer() to see if your code is running on the server. |
| DataModel | `IsGearTypeAllowed` | *(see note)* | This property is deprecated and is no longer functional. It should not be used. |
| DataModel | `SavePlace` | *(see note)* | This item is deprecated. Do not use it for new work. |
| DataStore | `RemoveVersionAsync` | *(see note)* | This method is deprecated. Do not use it for new work. |
| Debris | `addItem` | *(see note)* | This function is a deprecated variant of Debris:AddItem() which should be used instead. |
| EditableMesh | `GetFacesWithAttribute` | *(see note)* | This method is deprecated. Do not use it for new work. |
| EditableMesh | `GetVerticesWithAttribute` | *(see note)* | This method is deprecated. Do not use it for new work. |
| GamePassService | `PlayerHasPass` | *(none)* | Deprecated. |
| GlobalDataStore | `OnUpdate` | *(see note)* | This function has been deprecated and should not be used in new work. You can use the Cross Server Messaging Service to  |
| GuiObject | `TweenPosition` | *(see note)* | This function is deprecated in favor of using TweenService, which allows for better customization using an object-orient |
| GuiObject | `TweenSize` | *(see note)* | This function is deprecated in favor of using TweenService, which allows for better customization using an object-orient |
| GuiObject | `TweenSizeAndPosition` | *(see note)* | This function is deprecated in favor of using TweenService, which allows for better customization using an object-orient |
| GuiService | `AddSelectionParent` | *(none)* | Deprecated. |
| GuiService | `AddSelectionTuple` | *(none)* | Deprecated. |
| GuiService | `RemoveSelectionGroup` | *(none)* | Deprecated. |
| Humanoid | `AddCustomStatus` | *(see note)* | This item is deprecated, as it was a part of the unfinished RbxStatus library which would have allowed you to add condit |
| Humanoid | `AddStatus` | *(see note)* | This item is deprecated, as it was a part of the unfinished RbxStatus library which would have allowed you to add condit |
| Humanoid | `ApplyDescription` | `ApplyDescriptionAsync` | This method has been superseded by ApplyDescriptionAsync(). |
| Humanoid | `ApplyDescriptionReset` | `ApplyDescriptionResetAsync` | This method has been superseded by ApplyDescriptionResetAsync(). |
| Humanoid | `GetPlayingAnimationTracks` | *(none)* | Deprecated. |
| Humanoid | `GetStatuses` | *(see note)* | This item is deprecated, as it was a part of the unfinished RbxStatus library which would have allowed you to add condit |
| Humanoid | `HasCustomStatus` | *(see note)* | This item is deprecated, as it was a part of the unfinished RbxStatus library which would have allowed you to add condit |
| Humanoid | `HasStatus` | *(see note)* | This item is deprecated, as it was a part of the unfinished RbxStatus library which would have allowed you to add condit |
| Humanoid | `loadAnimation` | *(see note)* | This deprecated method is a variant of Humanoid:LoadAnimation(). Animator:LoadAnimation() should be used instead. |
| Humanoid | `LoadAnimation` | *(see note)* | This function is deprecated in favor of using Animator:LoadAnimation() directly (the Animator may be created while editi |
| Humanoid | `PlayEmote` | `PlayEmoteAsync` | This method has been superseded by PlayEmoteAsync(). |
| Humanoid | `RemoveCustomStatus` | *(see note)* | This item is deprecated, as it was a part of the unfinished RbxStatus library which would have allowed you to add condit |
| Humanoid | `RemoveStatus` | *(see note)* | This item is deprecated, as it was a part of the unfinished RbxStatus library which would have allowed you to add condit |
| Humanoid | `takeDamage` | *(see note)* | This deprecated method is a variant of Humanoid:TakeDamage(), which should be used instead. |
| InputAction | `Fire` | `InputBinding:Fire()` | Use InputBinding:Fire() with a Scriptable binding instead. |
| InsertService | `ApproveAssetId` | *(see note)* | This item is deprecated. Do not use it for new work. |
| InsertService | `ApproveAssetVersionId` | *(see note)* | This item is deprecated. Do not use it for new work. |
| InsertService | `GetBaseCategories` | *(see note)* | This item is deprecated. Do not use it for new work. |
| InsertService | `GetBaseSets` | *(see note)* | [Sets have been removed](https://devforum.roblox.com/t/sunsetting-sets/189402) from Roblox. |
| InsertService | `GetCollection` | *(see note)* | [Sets have been removed](https://devforum.roblox.com/t/sunsetting-sets/189402) from Roblox. |
| InsertService | `GetFreeDecals` | `GetFreeDecalsAsync` | Use GetFreeDecalsAsync() instead. |
| InsertService | `GetFreeModels` | `GetFreeModelsAsync` | Use GetFreeModelsAsync() instead. |
| InsertService | `GetUserCategories` | *(see note)* | This item is deprecated. Do not use it for new work. |
| InsertService | `GetUserSets` | *(see note)* | [Sets have been removed](https://devforum.roblox.com/t/sunsetting-sets/189402) from Roblox. |
| InsertService | `Insert` | `InsertService:LoadAsset()` | This function has been superseded by InsertService:LoadAsset() which should be used in all new work. |
| InsertService | `loadAsset` | *(see note)* | This function is a deprecated variant of InsertService:LoadAsset() which should be used instead. |
| Instance | `children` | `Instance:GetChildren()` | This item has been superseded by Instance:GetChildren() which should be used in all new work. |
| Instance | `clone` | *(see note)* | This deprecated function is a variant of Instance:Clone() which should be used instead. |
| Instance | `destroy` | *(see note)* | This deprecated function is a variant of Instance:Destroy() which should be used instead. |
| Instance | `findFirstChild` | *(see note)* | This deprecated function is a variant of Instance:FindFirstChild() which should be used instead. |
| Instance | `getChildren` | *(see note)* | This deprecated function is a variant of Instance:GetChildren() which should be used instead. |
| Instance | `isDescendantOf` | *(see note)* | This deprecated function is a variant of Instance:IsDescendantOf() which should be used instead. |
| Instance | `remove` | *(see note)* | This deprecated function is a variant of Instance:Remove() which has also been deprecated. Neither function should be us |
| Instance | `Remove` | *(see note)* | This item is deprecated in favor of Instance:Destroy() and Instance:ClearAllChildren(). If you must remove an object fro |
| KeyframeSequenceProvider | `GetAnimations` | *(none)* | Deprecated. |
| KeyframeSequenceProvider | `GetKeyframeSequence` | `KeyframeSequenceProvider:GetKeyframeSequenceAsync()` | This function is deprecated and can lead to the game freezing until the animation is loaded. Developers are recommended  |
| KeyframeSequenceProvider | `GetKeyframeSequenceById` | `KeyframeSequenceProvider:GetKeyframeSequenceAsync()` | This function is deprecated and can lead to the game freezing until the animation is loaded. Developers are recommended  |
| LayerCollector | `GetLayoutNodeTree` | *(see note)* | This method should not be used for new work. |
| Lighting | `getMinutesAfterMidnight` | *(see note)* | This method is a deprecated variant of Lighting:GetMinutesAfterMidnight() which should be used instead. |
| Lighting | `setMinutesAfterMidnight` | *(see note)* | This method is a deprecated variant of Lighting:SetMinutesAfterMidnight() which should be used instead. |
| LocalizationService | `GetTranslatorForPlayer` | *(see note)* | This function has been deprecated by LocalizationService:GetTranslatorForPlayerAsync(), which functions similarly except |
| LocalizationTable | `GetContents` | `LocalizationTable:GetEntries()` | This item has been superseded by LocalizationTable:GetEntries() which should be used in all new work. |
| LocalizationTable | `GetString` | `LocalizationTable:GetTranslator()` | This item has been superseded by LocalizationTable:GetTranslator() which should be used in all new work. |
| LocalizationTable | `RemoveKey` | `LocalizationTable:RemoveEntry()` | This item has been superseded by LocalizationTable:RemoveEntry() which should be used in all new work |
| LocalizationTable | `SetContents` | `LocalizationTable:SetEntries()` | This item has been superseded by LocalizationTable:SetEntries() which should be used in all new work |
| LocalizationTable | `SetEntry` | `LocalizationTable:SetEntries()` | This item has been superseded by LocalizationTable:SetEntries() which should be used in all new work. |
| MarketplaceService | `GetProductInfo` | `GetProductInfoAsync` | This method has been superseded by GetProductInfoAsync(). |
| MarketplaceService | `PlayerOwnsAsset` | `PlayerOwnsAssetAsync` | This method has been superseded by PlayerOwnsAssetAsync(). |
| MarketplaceService | `PlayerOwnsBundle` | `PlayerOwnsBundleAsync` | This method has been superseded by PlayerOwnsBundleAsync(). |
| MarketplaceService | `PromptPremiumPurchase` | `PromptRobloxSubscriptionPurchase` | This method has been superseded by PromptRobloxSubscriptionPurchase(). |
| Model | `breakJoints` | *(see note)* | This deprecated function is a variant of Model:BreakJoints() which should be used instead. |
| Model | `BreakJoints` | *(none)* | Deprecated. |
| Model | `GetModelCFrame` | `Model:GetPrimaryPartCFrame()` | This function has been deprecated as it did not provide reliable results. You can instead use Model:GetPrimaryPartCFrame |
| Model | `GetModelSize` | *(see note)* | This item is deprecated. Do not use it for new work. Developers can instead use Model.GetExtentsSize. |
| Model | `GetPrimaryPartCFrame` | *(none)* | Deprecated. |
| Model | `makeJoints` | *(see note)* | This deprecated function is a variant of Model:MakeJoints() which should be used instead. |
| Model | `MakeJoints` | *(see note)* | This joint type has been deprecated. Don't use it for new work. Use WeldConstraints and HingeConstraints instead. |
| Model | `move` | `Model:MoveTo()` | This item has been superseded by Model:MoveTo() which should be used in all new work |
| Model | `moveTo` | *(see note)* | This deprecated function is a variant of Model:MoveTo() which should be used instead. |
| Model | `ResetOrientationToIdentity` | *(see note)* | This function has been deprecated; it remains to prevent legacy scripts from throwing errors, but it does nothing when c |
| Model | `SetIdentityOrientation` | *(see note)* | This function has been deprecated; it remains to prevent legacy scripts from throwing errors, but it does nothing when c |
| Model | `SetPrimaryPartCFrame` | *(none)* | Deprecated. |
| Object | `isA` | *(see note)* | This deprecated function is a variant of Object:IsA() which should be used instead. |
| OpenCloudApiV1 | `CreateModel` | *(see note)* | This method is deprecated. Do not use it for new work. |
| OpenCloudApiV1 | `CreateUserNotificationAsync` | *(see note)* | This method is deprecated. Do not use it for new work. |
| OpenCloudService | `GetApiV1` | *(see note)* | This method is deprecated. Do not use it for new work. |
| OpenCloudService | `InvokeAsync` | *(see note)* | This method is deprecated. Do not use it for new work. |
| Path | `GetPointCoordinates` | `GetWaypoints` | This item has been superseded by GetWaypoints() which should be used in all new work instead. |
| PathfindingService | `ComputeRawPathAsync` | `PathfindingService:FindPathAsync()` | This item has been superseded by PathfindingService:FindPathAsync() which should be used in all new work instead. |
| PathfindingService | `ComputeSmoothPathAsync` | `PathfindingService:FindPathAsync()` | This item has been superseded by PathfindingService:FindPathAsync() which should be used in all new work instead. |
| PhysicsService | `CollisionGroupContainsPart` | *(see note)* | This method has been deprecated. It's recommended that you query a part's collision group through its CollisionGroup pro |
| PhysicsService | `CreateCollisionGroup` | `RegisterCollisionGroup` | This method has been superseded by RegisterCollisionGroup() which should be used for all new work. |
| PhysicsService | `GetCollisionGroupId` | *(see note)* | This method has been deprecated. It's recommended that you query collision groups by **name** through a part's Collision |
| PhysicsService | `GetCollisionGroupName` | *(see note)* | This method has been deprecated. It's recommended that you query collision groups by **name** through a part's Collision |
| PhysicsService | `GetCollisionGroups` | `GetRegisteredCollisionGroups` | This method has been superseded by GetRegisteredCollisionGroups() which should be used for all new work. |
| PhysicsService | `RemoveCollisionGroup` | `UnregisterCollisionGroup` | This method has been superseded by UnregisterCollisionGroup() which should be used for all new work. |
| PhysicsService | `SetPartCollisionGroup` | *(see note)* | This method has been deprecated. It's recommended that you set a part's collision group by **name** through its Collisio |
| Player | `GetFriendsOnline` | `GetFriendsOnlineAsync` | This method has been superseded by GetFriendsOnlineAsync(). |
| Player | `GetRankInGroup` | `GetRankInGroupAsync` | This method has been superseded by GetRankInGroupAsync(). |
| Player | `GetRankInGroupAsync` | `GroupService:GetRolesInGroupAsync()` | This method returns only the rank value of the member's highest public role. Use GroupService:GetRolesInGroupAsync() ins |
| Player | `GetRoleInGroup` | `GetRoleInGroup` | This method has been superseded by GetRoleInGroup(). |
| Player | `GetRoleInGroupAsync` | `GroupService:GetRolesInGroupAsync()` | This method returns only the member's highest public role. Use GroupService:GetRolesInGroupAsync() instead, which return |
| Player | `IsBestFriendsWith` | *(see note)* | This function is obsolete because the "best friends" feature was removed. Use Player:IsFriendsWithAsync() instead. |
| Player | `isFriendsWith` | *(see note)* | This method has been superseded by the Player:IsFriendsWithAsync() method which should be used for new work. |
| Player | `IsFriendsWith` | *(see note)* | This method has been superseded by the Player:IsFriendsWithAsync() method which should be used for new work. |
| Player | `IsInGroup` | `IsInGroupAsync` | This method has been superseded by IsInGroupAsync(). |
| Player | `loadBoolean` | *(see note)* | This deprecated function is a variant of Player:LoadBoolean() which has also been deprecated. Neither function should be |
| Player | `LoadBoolean` | *(see note)* | This item is deprecated, as it may have been used for a now obsolete data persistence method. Please save and load playe |
| Player | `LoadCharacter` | `LoadCharacterAsync` | This method has been superseded by LoadCharacterAsync(). |
| Player | `LoadCharacterAppearance` | *(see note)* | This method is deprecated. Do not use it for new work. |
| Player | `LoadCharacterWithHumanoidDescription` | `LoadCharacterWithHumanoidDescriptionAsync` | This method has been superseded by LoadCharacterWithHumanoidDescriptionAsync(). |
| Player | `loadInstance` | *(see note)* | This deprecated function is a variant of Player:LoadInstance() which has also been deprecated. Neither function should b |
| Player | `LoadInstance` | *(see note)* | This item is deprecated, as it may have been used for a now obsolete data persistence method. Please save and load playe |
| Player | `loadNumber` | *(see note)* | This deprecated function is a variant of Player:LoadNumber() which has also been deprecated. Neither function should be  |
| Player | `LoadNumber` | *(see note)* | This item is deprecated, as it may have been used for a now obsolete data persistence method. Please save and load playe |
| Player | `loadString` | *(see note)* | This function is a deprecated variant of Player:LoadString() which has also been deprecated. Neither function should be  |
| Player | `LoadString` | *(see note)* | This item is deprecated, as it may have been used for a now obsolete data persistence method. Please save and load playe |
| Player | `saveBoolean` | *(see note)* | This function is a deprecated variant of Player:SaveBoolean() which has also been deprecated. Neither function should be |
| Player | `SaveBoolean` | *(see note)* | This item is deprecated, as it may have been used for a now obsolete data persistence method. Please save and load playe |
| Player | `saveInstance` | *(see note)* | This function is a deprecated variant of Player:SaveInstance() which has also been deprecated. Neither function should b |
| Player | `SaveInstance` | *(see note)* | This item is deprecated, as it may have been used for a now obsolete data persistence method. Please save and load playe |
| Player | `saveNumber` | *(see note)* | This function is a deprecated variant of Player:SaveNumber() which has also been deprecated. Neither function should be  |
| Player | `SaveNumber` | *(see note)* | This item is deprecated, as it may have been used for a now obsolete data persistence method. Please save and load playe |
| Player | `saveString` | *(see note)* | This function is a deprecated variant of Player:SaveString() which has also been deprecated. Neither function should be  |
| Player | `SaveString` | *(see note)* | This item is deprecated, as it may have been used for a now obsolete data persistence method. Please save and load playe |
| Player | `waitForDataReady` | *(see note)* | This function is a deprecated variant of Player:WaitForDataReady() which has also been deprecated. Neither function shou |
| Player | `WaitForDataReady` | *(see note)* | This item is deprecated, as it may have been used for a now obsolete data persistence method. Please save and load playe |
| PlayerGui | `GetTopbarTransparency` | *(none)* | Deprecated. |
| PlayerGui | `SetTopbarTransparency` | *(none)* | Deprecated. |
| Players | `CreateHumanoidModelFromDescription` | `CreateHumanoidModelFromDescriptionAsync` | This method has been superseded by CreateHumanoidModelFromDescriptionAsync(). |
| Players | `CreateHumanoidModelFromUserId` | `CreateHumanoidModelFromUserIdAsync` | This method has been superseded by CreateHumanoidModelFromUserIdAsync(). |
| Players | `GetCharacterAppearanceAsync` | *(see note)* | This method is deprecated. Do not use it for new work. |
| Players | `GetHumanoidDescriptionFromOutfitId` | `GetHumanoidDescriptionFromOutfitIdAsync` | This method has been superseded by GetHumanoidDescriptionFromOutfitIdAsync(). |
| Players | `GetHumanoidDescriptionFromUserId` | `GetHumanoidDescriptionFromUserIdAsync` | This method has been superseded by GetHumanoidDescriptionFromUserIdAsync(). |
| Players | `getPlayers` | *(see note)* | This function is a deprecated variant of Players:GetPlayers() which should be used instead. |
| Players | `playerFromCharacter` | *(see note)* | This function is a deprecated variant of Players:GetPlayerFromCharacter() which should be used in new work. |
| Players | `players` | `Players:GetPlayers()` | This item has been superseded by Players:GetPlayers() which should be used in all new work. |
| Plugin | `CreateDockWidgetPluginGui` | `CreateDockWidgetPluginGuiAsync` | This method has been superseded by CreateDockWidgetPluginGuiAsync(). |
| Plugin | `GetStudioUserId` | *(none)* | Deprecated. |
| Plugin | `ImportFbxAnimation` | *(none)* | Deprecated. |
| Plugin | `ImportFbxRig` | `ImportFbxRigAsync` | This method has been superseded by ImportFbxRigAsync(). |
| Plugin | `OpenScript` | *(none)* | Deprecated. |
| Plugin | `PromptSaveSelection` | `PromptSaveSelectionAsync` | This method has been superseded by PromptSaveSelectionAsync(). |
| PluginManager | `CreatePlugin` | `Plugin` | The steps to create a plugin have changed. To learn more, see Plugin. |
| PluginManagerInterface | `CreatePlugin` | `Plugin` | The steps to create a plugin have changed. To learn more, see Plugin. |
| PointsService | `AwardPoints` | *(see note)* | This function was once part of the `PointService` class used to control an ancient achievement system since removed and  |
| PointsService | `GetAwardablePoints` | *(see note)* | This function was once part of the `PointService` class used to control an ancient achievement system since removed and  |
| PointsService | `GetGamePointBalance` | *(see note)* | This function was once part of the `PointService` class used to control an ancient achievement system since removed and  |
| PointsService | `GetPointBalance` | *(see note)* | This function was once part of the `PointService` class used to control an ancient achievement system since removed and  |
| RocketPropulsion | `fire` | *(see note)* | This function is a deprecated variant of RocketPropulsion:Fire() which should be used instead. |
| RunService | `Reset` | *(see note)* | This item is deprecated and should not be used in new work. |
| SensorBase | `Sense` | *(see note)* | This method should not be used in new work. |
| ServiceProvider | `getService` | *(see note)* | This deprecated function is a variant of ServiceProvider:GetService() which should be used instead. |
| ServiceProvider | `service` | `ServiceProvider:GetService()` | This item has been superseded by ServiceProvider:GetService() which should be used in all new work. |
| SocialService | `PromptLinkSharing` | `PromptLinkSharingAsync` | Use PromptLinkSharingAsync() instead. |
| Sound | `pause` | *(see note)* | This deprecated function is a variant of Sound:Pause() which should be used instead. |
| Sound | `play` | *(see note)* | This deprecated function is a variant of Sound:Play() which should be used instead. |
| Sound | `stop` | *(see note)* | This deprecated function is a variant of Sound:Stop() which should be used instead. |
| StudioService | `PromptImportFile` | *(none)* | Deprecated. |
| StudioService | `PromptImportFiles` | *(none)* | Deprecated. |
| Teams | `RebalanceTeams` | *(see note)* | This function has been deprecated and no longer functions correctly. It should not be used. Developers should instead im |
| TeleportService | `ReserveServer` | `TeleportAsync` | Use TeleportAsync() with TeleportOptions.ReservedServerId instead. Generate a GUID with HttpService:GenerateGUID() and p |
| TeleportService | `ReserveServerAsync` | `TeleportAsync` | Use TeleportAsync() with TeleportOptions.ReservedServerId instead. Generate a GUID with HttpService:GenerateGUID() and p |
| TeleportService | `TeleportPartyAsync` | `TeleportAsync` | Use TeleportAsync() instead. For a migration guide, see [Teleport between places](../../../projects/teleport.md#migrate- |
| TeleportService | `TeleportToPlaceInstance` | `TeleportAsync` | Use TeleportAsync() instead. For a migration guide, see [Teleport between places](../../../projects/teleport.md#migrate- |
| TeleportService | `TeleportToPrivateServer` | `TeleportAsync` | Use TeleportAsync() with TeleportOptions.ReservedServerId instead. Generate a GUID with HttpService:GenerateGUID() and p |
| TeleportService | `TeleportToSpawnByName` | `TeleportAsync` | Use TeleportAsync() instead. For a migration guide, see [Teleport between places](../../../projects/teleport.md#migrate- |
| Terrain | `AutowedgeCell` | *(see note)* | This item is a deprecated function of a legacy Terrain engine that has been removed. Do not use it for new work. |
| Terrain | `AutowedgeCells` | *(see note)* | This item is a deprecated function of a legacy Terrain engine that has been removed. Do not use it for new work. |
| Terrain | `ConvertToSmooth` | *(see note)* | Since all places now automatically use the new terrain engine, this method is obsolete. |
| Terrain | `GetCell` | *(see note)* | This item is a deprecated function of a legacy Terrain engine that has been removed. Do not use it for new work. |
| Terrain | `GetWaterCell` | *(see note)* | This item is a deprecated function of a legacy Terrain engine that has been removed. Do not use it for new work. |
| Terrain | `SetCell` | *(see note)* | This item is a deprecated function of a legacy Terrain engine that has been removed. Do not use it for new work. |
| Terrain | `SetCells` | *(see note)* | This item is a deprecated function of a legacy Terrain engine that has been removed. Do not use it for new work. |
| Terrain | `SetWaterCell` | *(see note)* | This item is a deprecated function of a legacy Terrain engine that has been removed. Do not use it for new work. |
| TerrainRegion | `ConvertToSmooth` | *(see note)* | This item is a deprecated function of a legacy Terrain engine that has been removed. Do not use it for new work. |
| TestService | `Run` | `RunAsync` | Use RunAsync() instead. |
| TextFilterResult | `GetChatForUserAsync` | *(see note)* | This method is deprecated and returns an empty string. Text filtering pertaining to chat should be done through TextChat |
| UIGridStyleLayout | `ApplyLayout` | *(none)* | Deprecated. |
| UIGridStyleLayout | `SetCustomSortFunction` | *(see note)* | This method is deprecated in favor of using other SortOrder means, such as by Name or LayoutOrder. |
| UserInputService | `GetUserCFrame` | `VRService:GetUserCFrame()` | Use VRService:GetUserCFrame() instead. |
| Workspace | `BreakJoints` | *(see note)* | This method is deprecated. Do not use it for new work. |
| Workspace | `MakeJoints` | *(see note)* | This method is deprecated. Do not use it for new work. |
| WorldRoot | `findPartOnRay` | *(see note)* | This deprecated function is a variant of WorldRoot:FindPartOnRay() which should be used instead. |
| WorldRoot | `FindPartOnRay` | `WorldRoot:Raycast()` | This function has been deprecated. Use WorldRoot:Raycast() along with RaycastParams for new work. |
| WorldRoot | `FindPartOnRayWithIgnoreList` | `WorldRoot:Raycast()` | This function has been deprecated. Use WorldRoot:Raycast() along with RaycastParams for new work. |
| WorldRoot | `FindPartOnRayWithWhitelist` | `WorldRoot:Raycast()` | This function has been deprecated. Use WorldRoot:Raycast() along with RaycastParams for new work. |
| WorldRoot | `findPartsInRegion3` | *(see note)* | This deprecated function is a variant of WorldRoot:FindPartsInRegion3() which should be used instead. |
| WorldRoot | `FindPartsInRegion3` | `WorldRoot:GetPartBoundsInBox()` | This function has been deprecated. Use WorldRoot:GetPartBoundsInBox() along with OverlapParams for new work. |
| WorldRoot | `FindPartsInRegion3WithIgnoreList` | `WorldRoot:GetPartBoundsInBox()` | This function has been deprecated. Use WorldRoot:GetPartBoundsInBox() along with OverlapParams for new work. |
| WorldRoot | `FindPartsInRegion3WithWhiteList` | `WorldRoot:GetPartBoundsInBox()` | This function has been deprecated. Use WorldRoot:GetPartBoundsInBox() along with OverlapParams for new work. |
| WorldRoot | `IsRegion3Empty` | `WorldRoot:GetPartBoundsInBox()` | This function has been deprecated. Use WorldRoot:GetPartBoundsInBox() along with OverlapParams for new work. |
| WorldRoot | `IsRegion3EmptyWithIgnoreList` | `WorldRoot:GetPartBoundsInBox()` | This function has been deprecated. Use WorldRoot:GetPartBoundsInBox() along with OverlapParams for new work. |

## Deprecated Events (38)

| Class/Type | Member | Replacement | Note |
|------------|--------|-------------|------|
| AdService | `VideoAdClosed` | *(see note)* | VideoAdClosed has been decommissioned and is no longer operational. |
| AnimationController | `AnimationPlayed` | *(none)* | Deprecated. |
| BasePart | `LocalSimulationTouched` | *(see note)* | This event is deprecated in favor of BasePart.Touched. |
| BasePart | `OutfitChanged` | *(see note)* | This event is deprecated. Do not use it for new work. |
| BasePart | `StoppedTouching` | *(see note)* | This event is deprecated in favor of BasePart.TouchEnded, which should be used instead. |
| BoolValue | `changed` | *(see note)* | This event is a deprecated variant of BoolValue.Changed which should be used instead. |
| BrickColorValue | `changed` | *(see note)* | This event is a deprecated variant of BrickColorValue.Changed which should be used instead. |
| CaptureService | `CaptureSaved` | *(see note)* | This event has been superseded by the UserCaptureSaved event. |
| CFrameValue | `changed` | *(see note)* | This event is a deprecated variant of CFrameValue.Changed which should be used instead. |
| ClickDetector | `mouseClick` | *(see note)* | This deprecated event is a variant of ClickDetector.MouseClick, which should be used instead. |
| CollectionService | `ItemAdded` | *(see note)* | This item has been superseded by a CollectionService tagging method. There is currently no means of checking when a tag  |
| CollectionService | `ItemRemoved` | *(see note)* | This item has been superseded by a CollectionService tagging method. There is currently no means of checking when a tag  |
| Color3Value | `changed` | *(see note)* | This deprecated event is a variant of Color3Value.Changed which should be used instead. |
| DataModel | `AllowedGearTypeChanged` | *(see note)* | This item is deprecated . Do not use it for new work. |
| DataModel | `ItemChanged` | `Object.Changed` | This function has been superseded by Object.Changed, which should be used in new work instead. |
| DoubleConstrainedValue | `changed` | *(see note)* | This event is a deprecated variant of DoubleConstrainedValue.Changed which has also been deprecated. Neither event shoul |
| GuiObject | `DragBegin` | `UIDragDetector` | This property is deprecated. Use UIDragDetector instead, as it supports more input types and can be better customized. |
| GuiObject | `DragStopped` | `UIDragDetector` | This property is deprecated. Use UIDragDetector instead, as it supports more input types and can be better customized. |
| Humanoid | `AnimationPlayed` | *(none)* | Deprecated. |
| Humanoid | `CustomStatusAdded` | *(see note)* | This item is deprecated, as it was a part of the unfinished RbxStatus library which would have allowed you to add condit |
| Humanoid | `CustomStatusRemoved` | *(see note)* | This item is deprecated, as it was a part of the unfinished RbxStatus library which would have allowed you to add condit |
| Humanoid | `StatusAdded` | *(see note)* | This item is deprecated, as it was a part of the unfinished RbxStatus library which would have allowed you to add condit |
| Humanoid | `StatusRemoved` | *(see note)* | This item is deprecated, as it was a part of the unfinished RbxStatus library which would have allowed you to add condit |
| Instance | `childAdded` | *(see note)* | This deprecated event is a variant of Instance.ChildAdded which should be used instead. |
| IntConstrainedValue | `changed` | *(see note)* | This deprecated event is a variant of IntConstrainedValue.Changed which has also been deprecated. Neither event should b |
| IntValue | `changed` | *(see note)* | This deprecated event is a variant of IntValue.Changed which should be used instead. |
| Mouse | `keyDown` | *(see note)* | This event is a deprecated variant of Mouse.KeyDown which has also been deprecated. Neither event should be used in new  |
| Mouse | `KeyDown` | *(see note)* | Mouse events have been superseded by UserInputService which should be used in all new work. |
| Mouse | `KeyUp` | *(see note)* | Mouse events have been superseded by UserInputService which should be used in all new work. |
| NumberValue | `changed` | *(see note)* | This event is a deprecated variant of NumberValue.Changed which should be used instead. |
| ObjectValue | `changed` | *(see note)* | This event is a deprecated variant of ObjectValue.Changed which should be used instead. |
| PlayerGui | `TopbarTransparencyChangedSignal` | *(none)* | Deprecated. |
| RayValue | `changed` | *(see note)* | This event is a deprecated variant of RayValue.Changed which should be used instead. |
| SkateboardPlatform | `equipped` | *(see note)* | This deprecated event is a variant of SkateboardPlatform.Equipped which has also been deprecated. Neither event should b |
| SkateboardPlatform | `unequipped` | *(see note)* | This deprecated event is a variant of SkateboardPlatform.Unequipped which has also been deprecated. Neither event should |
| StringValue | `changed` | *(see note)* | This deprecated event is a variant of StringValue.Changed which should be used instead. |
| UserInputService | `UserCFrameChanged` | `VRService.UserCFrameChanged` | Use VRService.UserCFrameChanged instead. |
| Vector3Value | `changed` | *(see note)* | This deprecated event is a variant of Vector3Value.Changed which should be used instead. |

## Deprecated Callbacks (2)

| Class/Type | Member | Replacement | Note |
|------------|--------|-------------|------|
| AdGui | `OnAdEvent` | *(see note)* | This callback has been deprecated and will never be called. |
| DataModel | `OnClose` | `DataModel:BindToClose()` | This function is deprecated. It is recommended to use DataModel:BindToClose() instead. |

## Deprecated Functions (15)

| Class/Type | Member | Replacement | Note |
|------------|--------|-------------|------|
| Luau globals | `collectgarbage` | *(none)* | Deprecated. |
| Luau globals | `getfenv` | *(see note)* | This function allows uncontrolled change of the global/function environment and disables script optimizations. Changes t |
| Luau globals | `setfenv` | *(see note)* | This function allows uncontrolled change of the global/function environment and disables script optimizations. Changes t |
| Roblox globals | `DebuggerManager` | *(see note)* | The `DebuggerManager` is obsolete and serves little to no use case for developers. |
| Roblox globals | `delay` | `task.delay()` | This method has been superseded by task.delay() and should not be used for future work. |
| Roblox globals | `elapsedTime` | *(none)* | Deprecated. |
| Roblox globals | `printidentity` | *(none)* | Deprecated. |
| Roblox globals | `spawn` | `task.spawn()` | This method has been superseded by task.spawn() and should not be used for future work. |
| Roblox globals | `stats` | *(none)* | Deprecated. |
| Roblox globals | `version` | *(none)* | Deprecated. |
| Roblox globals | `wait` | `task.wait()` | This method has been superseded by task.wait() and should not be used for future work. |
| Roblox globals | `ypcall` | *(none)* | Deprecated. |
| table | `foreach` | *(none)* | Deprecated. |
| table | `foreachi` | *(none)* | Deprecated. |
| table | `getn` | *(none)* | Deprecated. |

## Deprecated Enum Items (160)

| Class/Type | Member | Replacement | Note |
|------------|--------|-------------|------|
| AlignType | `Parallel` | *(none)* | Deprecated enum item. |
| AlignType | `Perpendicular` | *(none)* | Deprecated enum item. |
| AvatarSettingsAnimationClipsMode | `CustomClips` | *(none)* | Deprecated enum item. |
| AvatarSettingsAnimationClipsMode | `PlayerChoice` | *(none)* | Deprecated enum item. |
| AvatarSettingsAppearanceMode | `CustomBody` | *(none)* | Deprecated enum item. |
| AvatarSettingsAppearanceMode | `CustomParts` | *(none)* | Deprecated enum item. |
| AvatarSettingsAppearanceMode | `PlayerChoice` | *(none)* | Deprecated enum item. |
| AvatarSettingsCustomAccessoryMode | `CustomAccessories` | *(none)* | Deprecated enum item. |
| AvatarSettingsCustomAccessoryMode | `PlayerChoice` | *(none)* | Deprecated enum item. |
| AvatarSettingsCustomBodyType | `AvatarReference` | *(none)* | Deprecated enum item. |
| AvatarSettingsCustomBodyType | `BundleId` | *(none)* | Deprecated enum item. |
| AvatarSettingsCustomClothingMode | `CustomClothing` | *(none)* | Deprecated enum item. |
| AvatarSettingsCustomClothingMode | `PlayerChoice` | *(none)* | Deprecated enum item. |
| AvatarSettingsLegacyCollisionMode | `InnerBoxColliders` | *(none)* | Deprecated enum item. |
| AvatarSettingsLegacyCollisionMode | `R6Colliders` | *(none)* | Deprecated enum item. |
| AvatarUnificationMode | `Default` | *(none)* | Deprecated enum item. |
| AvatarUnificationMode | `Disabled` | *(none)* | Deprecated enum item. |
| AvatarUnificationMode | `Enabled` | *(none)* | Deprecated enum item. |
| CatalogCategoryFilter | `Collectibles` | *(none)* | Deprecated enum item. |
| GearGenreSetting | `AllGenres` | *(none)* | Deprecated enum item. |
| GearGenreSetting | `MatchingGenreOnly` | *(none)* | Deprecated enum item. |
| GearType | `BuildingTools` | *(none)* | Deprecated enum item. |
| GearType | `Explosives` | *(none)* | Deprecated enum item. |
| GearType | `MeleeWeapons` | *(none)* | Deprecated enum item. |
| GearType | `MusicalInstruments` | *(none)* | Deprecated enum item. |
| GearType | `NavigationEnhancers` | *(none)* | Deprecated enum item. |
| GearType | `PowerUps` | *(none)* | Deprecated enum item. |
| GearType | `RangedWeapons` | *(none)* | Deprecated enum item. |
| GearType | `SocialItems` | *(none)* | Deprecated enum item. |
| GearType | `Transport` | *(none)* | Deprecated enum item. |
| KeyCode | `MouseBackButton` | *(none)* | Deprecated enum item. |
| KeyCode | `MouseNoButton` | *(none)* | Deprecated enum item. |
| KeyCode | `MouseX` | *(none)* | Deprecated enum item. |
| KeyCode | `MouseY` | *(none)* | Deprecated enum item. |
| KeyCode | `World0` | *(none)* | Deprecated enum item. |
| KeyCode | `World1` | *(none)* | Deprecated enum item. |
| KeyCode | `World10` | *(none)* | Deprecated enum item. |
| KeyCode | `World11` | *(none)* | Deprecated enum item. |
| KeyCode | `World12` | *(none)* | Deprecated enum item. |
| KeyCode | `World13` | *(none)* | Deprecated enum item. |
| KeyCode | `World14` | *(none)* | Deprecated enum item. |
| KeyCode | `World15` | *(none)* | Deprecated enum item. |
| KeyCode | `World16` | *(none)* | Deprecated enum item. |
| KeyCode | `World17` | *(none)* | Deprecated enum item. |
| KeyCode | `World18` | *(none)* | Deprecated enum item. |
| KeyCode | `World19` | *(none)* | Deprecated enum item. |
| KeyCode | `World2` | *(none)* | Deprecated enum item. |
| KeyCode | `World20` | *(none)* | Deprecated enum item. |
| KeyCode | `World21` | *(none)* | Deprecated enum item. |
| KeyCode | `World22` | *(none)* | Deprecated enum item. |
| KeyCode | `World23` | *(none)* | Deprecated enum item. |
| KeyCode | `World24` | *(none)* | Deprecated enum item. |
| KeyCode | `World25` | *(none)* | Deprecated enum item. |
| KeyCode | `World26` | *(none)* | Deprecated enum item. |
| KeyCode | `World27` | *(none)* | Deprecated enum item. |
| KeyCode | `World28` | *(none)* | Deprecated enum item. |
| KeyCode | `World29` | *(none)* | Deprecated enum item. |
| KeyCode | `World3` | *(none)* | Deprecated enum item. |
| KeyCode | `World30` | *(none)* | Deprecated enum item. |
| KeyCode | `World31` | *(none)* | Deprecated enum item. |
| KeyCode | `World32` | *(none)* | Deprecated enum item. |
| KeyCode | `World33` | *(none)* | Deprecated enum item. |
| KeyCode | `World34` | *(none)* | Deprecated enum item. |
| KeyCode | `World35` | *(none)* | Deprecated enum item. |
| KeyCode | `World36` | *(none)* | Deprecated enum item. |
| KeyCode | `World37` | *(none)* | Deprecated enum item. |
| KeyCode | `World38` | *(none)* | Deprecated enum item. |
| KeyCode | `World39` | *(none)* | Deprecated enum item. |
| KeyCode | `World4` | *(none)* | Deprecated enum item. |
| KeyCode | `World40` | *(none)* | Deprecated enum item. |
| KeyCode | `World41` | *(none)* | Deprecated enum item. |
| KeyCode | `World42` | *(none)* | Deprecated enum item. |
| KeyCode | `World43` | *(none)* | Deprecated enum item. |
| KeyCode | `World44` | *(none)* | Deprecated enum item. |
| KeyCode | `World45` | *(none)* | Deprecated enum item. |
| KeyCode | `World46` | *(none)* | Deprecated enum item. |
| KeyCode | `World47` | *(none)* | Deprecated enum item. |
| KeyCode | `World48` | *(none)* | Deprecated enum item. |
| KeyCode | `World49` | *(none)* | Deprecated enum item. |
| KeyCode | `World5` | *(none)* | Deprecated enum item. |
| KeyCode | `World50` | *(none)* | Deprecated enum item. |
| KeyCode | `World51` | *(none)* | Deprecated enum item. |
| KeyCode | `World52` | *(none)* | Deprecated enum item. |
| KeyCode | `World53` | *(none)* | Deprecated enum item. |
| KeyCode | `World54` | *(none)* | Deprecated enum item. |
| KeyCode | `World55` | *(none)* | Deprecated enum item. |
| KeyCode | `World56` | *(none)* | Deprecated enum item. |
| KeyCode | `World57` | *(none)* | Deprecated enum item. |
| KeyCode | `World58` | *(none)* | Deprecated enum item. |
| KeyCode | `World59` | *(none)* | Deprecated enum item. |
| KeyCode | `World6` | *(none)* | Deprecated enum item. |
| KeyCode | `World60` | *(none)* | Deprecated enum item. |
| KeyCode | `World61` | *(none)* | Deprecated enum item. |
| KeyCode | `World62` | *(none)* | Deprecated enum item. |
| KeyCode | `World63` | *(none)* | Deprecated enum item. |
| KeyCode | `World64` | *(none)* | Deprecated enum item. |
| KeyCode | `World65` | *(none)* | Deprecated enum item. |
| KeyCode | `World66` | *(none)* | Deprecated enum item. |
| KeyCode | `World67` | *(none)* | Deprecated enum item. |
| KeyCode | `World68` | *(none)* | Deprecated enum item. |
| KeyCode | `World69` | *(none)* | Deprecated enum item. |
| KeyCode | `World7` | *(none)* | Deprecated enum item. |
| KeyCode | `World70` | *(none)* | Deprecated enum item. |
| KeyCode | `World71` | *(none)* | Deprecated enum item. |
| KeyCode | `World72` | *(none)* | Deprecated enum item. |
| KeyCode | `World73` | *(none)* | Deprecated enum item. |
| KeyCode | `World74` | *(none)* | Deprecated enum item. |
| KeyCode | `World75` | *(none)* | Deprecated enum item. |
| KeyCode | `World76` | *(none)* | Deprecated enum item. |
| KeyCode | `World77` | *(none)* | Deprecated enum item. |
| KeyCode | `World78` | *(none)* | Deprecated enum item. |
| KeyCode | `World79` | *(none)* | Deprecated enum item. |
| KeyCode | `World8` | *(none)* | Deprecated enum item. |
| KeyCode | `World80` | *(none)* | Deprecated enum item. |
| KeyCode | `World81` | *(none)* | Deprecated enum item. |
| KeyCode | `World82` | *(none)* | Deprecated enum item. |
| KeyCode | `World83` | *(none)* | Deprecated enum item. |
| KeyCode | `World84` | *(none)* | Deprecated enum item. |
| KeyCode | `World85` | *(none)* | Deprecated enum item. |
| KeyCode | `World86` | *(none)* | Deprecated enum item. |
| KeyCode | `World87` | *(none)* | Deprecated enum item. |
| KeyCode | `World88` | *(none)* | Deprecated enum item. |
| KeyCode | `World89` | *(none)* | Deprecated enum item. |
| KeyCode | `World9` | *(none)* | Deprecated enum item. |
| KeyCode | `World90` | *(none)* | Deprecated enum item. |
| KeyCode | `World91` | *(none)* | Deprecated enum item. |
| KeyCode | `World92` | *(none)* | Deprecated enum item. |
| KeyCode | `World93` | *(none)* | Deprecated enum item. |
| KeyCode | `World94` | *(none)* | Deprecated enum item. |
| KeyCode | `World95` | *(none)* | Deprecated enum item. |
| MeshType | `CornerWedge` | *(none)* | Deprecated enum item. |
| MeshType | `ParallelRamp` | *(none)* | Deprecated enum item. |
| MeshType | `Prism` | *(none)* | Deprecated enum item. |
| MeshType | `Pyramid` | *(none)* | Deprecated enum item. |
| MeshType | `RightAngleRamp` | *(none)* | Deprecated enum item. |
| PathStatus | `ClosestNoPath` | *(none)* | Deprecated enum item. |
| PathStatus | `ClosestOutOfRange` | *(none)* | Deprecated enum item. |
| PathStatus | `FailFinishNotEmpty` | *(none)* | Deprecated enum item. |
| PathStatus | `FailStartNotEmpty` | *(none)* | Deprecated enum item. |
| SecurityCapability | `AssetRequire` | *(none)* | Deprecated enum item. |
| SecurityCapability | `Avatar` | *(none)* | Deprecated enum item. |
| SortOrder | `Custom` | *(none)* | Deprecated enum item. |
| StateObjectFieldType | `Boolean` | *(none)* | Deprecated enum item. |
| StateObjectFieldType | `CFrame` | *(none)* | Deprecated enum item. |
| StateObjectFieldType | `Color3` | *(none)* | Deprecated enum item. |
| StateObjectFieldType | `Float` | *(none)* | Deprecated enum item. |
| StateObjectFieldType | `Instance` | *(none)* | Deprecated enum item. |
| StateObjectFieldType | `INVALID` | *(none)* | Deprecated enum item. |
| StateObjectFieldType | `Random` | *(none)* | Deprecated enum item. |
| StateObjectFieldType | `Vector2` | *(none)* | Deprecated enum item. |
| StateObjectFieldType | `Vector3` | *(none)* | Deprecated enum item. |
| Status | `Confusion` | *(none)* | Deprecated enum item. |
| Status | `Poison` | *(none)* | Deprecated enum item. |
| StreamingPauseMode | `ClientPhysicsPause` | *(none)* | Deprecated enum item. |
| StreamingPauseMode | `Default` | *(none)* | Deprecated enum item. |
| StreamingPauseMode | `Disabled` | *(none)* | Deprecated enum item. |
| Technology | `Legacy` | *(none)* | Deprecated enum item. |
| Technology | `Unified` | *(none)* | Deprecated enum item. |
| UITheme | `Dark` | *(none)* | Deprecated enum item. |
| UITheme | `Light` | *(none)* | Deprecated enum item. |
