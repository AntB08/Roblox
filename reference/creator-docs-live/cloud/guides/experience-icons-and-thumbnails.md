---
title: "Manage experience icons and thumbnails"
url: /docs/en-us/cloud/guides/experience-icons-and-thumbnails
last_updated: 2026-11-05T19:15:50Z
description: "Explains how to update a place icon, experience detail page thumbnails, and homepage thumbnails with Open Cloud."
---

# Manage experience icons and thumbnails

Experiences are associated with various icon/thumbnail media. The [place icon](/docs/en-us/production/publishing/experience-icons.md) is a single square image. [Experience detail page thumbnails](/docs/en-us/production/publishing/thumbnails.md) are an ordered list on the game page. [Homepage thumbnails](/docs/en-us/production/publishing/thumbnails.md#home-page-personalization) are the images Roblox can rotate on the Home page. The terms 'thumbnail' and 'preview' are interchangeable.

| Image | Identifier | Request |
| --- | --- | --- |
| [**Place icon**](#update-the-place-icon) | Place ID | [Update Asset](/docs/en-us/cloud/reference/features/assets.md#Assets_UpdateAsset) with `updateMask=icon` |
| [**Translated icon**](#update-a-translated-icon) | Universe ID and language code | [Update a game's icon](/docs/en-us/cloud/reference/features/localization.md#post_legacy_game_internationalization_v1_game_icon_games__gameId__language_codes__languageCode_) |
| [**Experience detail page thumbnails**](#update-experience-detail-page-thumbnails) | Place ID | [Update Asset](/docs/en-us/cloud/reference/features/assets.md#Assets_UpdateAsset) with `updateMask=previews` |
| [**Homepage thumbnails**](#update-homepage-thumbnails) | Universe ID and homepage thumbnail IDs | [Thumbnail Personalization API](/docs/en-us/cloud/reference/features/thumbnail-personalization.md) |

## Before you call the API

[Create an API key](/docs/en-us/cloud/auth/api-keys.md) and send it in the `x-api-key` header.

- For the place icon and experience detail page thumbnails, add **assets** to **Access Permissions** and grant **Read** and **Write** on the game. These calls use the `asset:read` and `asset:write` scopes.
- Homepage thumbnail calls require the `universe.thumbnail:read` and `universe.thumbnail:write` scopes on that game.
- Translated icon calls require the `legacy-universe:manage` scope.

The icon and detail-page calls take the **Place ID**. Homepage calls take the **Universe ID**. Copy both from the [Creator Dashboard](https://create.roblox.com/dashboard/creations):

1. Hover over the game's thumbnail, click the **⋯** button, and select **Copy Universe ID**.
2. Open the game, then open **Configurations** > **Places**.
3. Open the start place. The **Place ID** is in the URL. For example, in `https://create.roblox.com/dashboard/creations/experiences/0000000/places/111111/configure`, the Place ID is `111111`.

The same icon and preview calls work for a place other than the start place. Pass that place's ID when the image belongs to that place.

## Upload the image

The place icon and experience detail page thumbnails store a path to an existing **Image** asset, such as `assets/2205400862`. Upload the file with [Create Asset](/docs/en-us/cloud/reference/features/assets.md#Assets_CreateAsset), then poll [Get Operation](/docs/en-us/cloud/reference/features/assets.md#Assets_GetOperation) until `done` is `true`. Read `response.assetId` from that operation. For the full upload flow, limits, and group ownership, see the [usage guide for assets](/docs/en-us/cloud/guides/usage-assets.md).

Use `userId` when you own the game. Use `groupId` instead when a group owns it.

```bash
curl --location 'https://apis.roblox.com/assets/v1/assets' \
--header 'x-api-key: ${ApiKey}' \
--form 'request="{
  \"assetType\": \"Image\",
  \"displayName\": \"Experience image\",
  \"description\": \"Image for an experience icon or thumbnail\",
  \"creationContext\": {
    \"creator\": {
      \"userId\": \"${UserId}\"
    }
  }
}";type=application/json' \
--form 'fileContent=@"/filepath/image.png";type=image/png'
```

Prepare the file before uploading. A place icon must be square, and a non-square file is rejected. For the recommended sizes and other image requirements, see [Icons](/docs/en-us/production/publishing/experience-icons.md#best-practices) and [Thumbnails](/docs/en-us/production/publishing/thumbnails.md#best-practices).

Players see the image after moderation approves it. The operation response includes `moderationResult.moderationState`.

## Update the place icon

**Main article:** [Icons](/docs/en-us/production/publishing/experience-icons.md)

Send **Update Asset** on the place. Set `updateMask` to `icon` and set `icon` to the image asset path. Omit `fileContent`. This call replaces the source-language icon.

```bash
curl --location --request PATCH 'https://apis.roblox.com/assets/v1/assets/${PlaceId}?updateMask=icon' \
--header 'x-api-key: ${ApiKey}' \
--form 'request="{
  \"assetId\": \"${PlaceId}\",
  \"icon\": \"assets/${ImageAssetId}\"
}";type=application/json'
```

To remove the icon, send the same request with `icon` set to an empty string.

## Update a translated icon

**Main article:** [Icons](/docs/en-us/production/publishing/experience-icons.md)

The [localized game-icon endpoint](/docs/en-us/cloud/reference/features/localization.md#post_legacy_game_internationalization_v1_game_icon_games__gameId__language_codes__languageCode_) updates an icon for a language other than the source language. A request for the source language is rejected. Use [Update the place icon](#update-the-place-icon) for the icon players see before any translation.

`gameId` is the **Universe ID**. `Files` is the square icon image.

```bash
curl --location --request POST 'https://apis.roblox.com/legacy-game-internationalization/v1/game-icon/games/${UniverseId}/language-codes/${LanguageCode}' \
--header 'x-api-key: ${ApiKey}' \
--form 'Files=@"/filepath/icon.png"'
```

## Update experience detail page thumbnails

**Main article:** [Thumbnails](/docs/en-us/production/publishing/thumbnails.md)

Detail-page thumbnails are the place asset's `previews` list. Each entry is an image asset path plus optional alt text. The array order is the order on the game page.

`updateMask=previews` replaces the whole list. Include every thumbnail that should remain, including thumbnails that only move to a new position. Leave a thumbnail out to remove it. Send one entry to make that image the only detail-page thumbnail.

Read the current list before you change it:

```bash
curl --location 'https://apis.roblox.com/assets/v1/assets/${PlaceId}?readMask=previews' \
--header 'x-api-key: ${ApiKey}'
```

Upload any new files first, then send the full list:

```bash
curl --location --request PATCH 'https://apis.roblox.com/assets/v1/assets/${PlaceId}?updateMask=previews' \
--header 'x-api-key: ${ApiKey}' \
--form 'request="{
  \"assetId\": \"${PlaceId}\",
  \"previews\": [
    {
      \"asset\": \"assets/${FirstImageAssetId}\",
      \"altText\": \"Players racing through the city\"
    },
    {
      \"asset\": \"assets/${SecondImageAssetId}\",
      \"altText\": \"A close view of the new vehicle\"
    }
  ]
}";type=application/json'
```

This request updates the image list. For how many images or videos a game can show, and for video thumbnails and alt text, see [Thumbnails](/docs/en-us/production/publishing/thumbnails.md).

## Update homepage thumbnails

**Main article:** [Home page personalization](/docs/en-us/production/publishing/thumbnails.md#home-page-personalization)

Homepage thumbnails use the [Thumbnail Personalization API](/docs/en-us/cloud/reference/features/thumbnail-personalization.md), not `previews`. Upload through that API, wait for a **homepage thumbnail ID**, and then save the active set. The ID in `homepageThumbnailIds` is the homepage thumbnail ID, not the image asset ID and not a path such as `assets/2205400862`.

Follow the image requirements and activation rules in [Home page personalization](/docs/en-us/production/publishing/thumbnails.md#home-page-personalization).

### Upload a homepage thumbnail

```bash
curl --location --request POST 'https://apis.roblox.com/thumbnail-personalization-api/v1/universes/${UniverseId}/thumbnails/uploads' \
--header 'x-api-key: ${ApiKey}' \
--form 'files=@"/filepath/thumbnail.png"'
```

The response maps each file name to an operation ID in `fileToOperationIdDict`. Poll that operation until `uploadThumbnailStatusDict` includes it, then copy `homepageThumbnailId`:

```bash
curl --location 'https://apis.roblox.com/thumbnail-personalization-api/v1/universes/${UniverseId}/thumbnails/uploads/status?operationIds=${OperationId}' \
--header 'x-api-key: ${ApiKey}'
```

To reuse a thumbnail that is already on the homepage, list them and match `assetId`. An approved video thumbnail is included the same way as an image: the list entry's `assetId` is the video asset, and `homepageThumbnailIds` takes that entry's `homepageThumbnailId`. The upload request on this API accepts image files. For video rules and the monthly quota, see [Thumbnails](/docs/en-us/production/publishing/thumbnails.md#videos).

```bash
curl --location 'https://apis.roblox.com/thumbnail-personalization-api/v1/universes/${UniverseId}/thumbnails' \
--header 'x-api-key: ${ApiKey}'
```

### Choose the active homepage thumbnails

[Create a configuration](/docs/en-us/cloud/reference/features/thumbnail-personalization.md#ThumbnailPersonalizationApi.HomepageThumbnail_CreateThumbnailPersonalization) when you want a new active set. This deactivates the previous configuration and starts new statistics. The list can contain up to five homepage thumbnail IDs. This example leaves a single thumbnail active:

```bash
curl --location --request POST 'https://apis.roblox.com/thumbnail-personalization-api/v1/universes/${UniverseId}/personalization/create' \
--header 'x-api-key: ${ApiKey}' \
--header 'Content-Type: application/json' \
--data '{
  "homepageThumbnailIds": ["${HomepageThumbnailId}"]
}'
```

[Update the active configuration](/docs/en-us/cloud/reference/features/thumbnail-personalization.md#ThumbnailPersonalizationApi.HomepageThumbnail_UpdateThumbnailPersonalization) to change the active set without resetting its statistics. Read the active configuration first and send its `id` back:

```bash
curl --location 'https://apis.roblox.com/thumbnail-personalization-api/v1/universes/${UniverseId}/personalization?status=Active' \
--header 'x-api-key: ${ApiKey}'
```

```bash
curl --location --request POST 'https://apis.roblox.com/thumbnail-personalization-api/v1/universes/${UniverseId}/personalization/update' \
--header 'x-api-key: ${ApiKey}' \
--header 'Content-Type: application/json' \
--data '{
  "id": "${ConfigurationId}",
  "homepageThumbnailIds": ["${HomepageThumbnailId}"]
}'
```

`homepageThumbnailIds` specifies the active thumbnails. Their order in the list does not matter. Personalization chooses which active thumbnail each player sees.
</document>

<document url="/docs/en-us/cloud/guides/experience-notifications.md" title="User notifications">
