.. _extensions-asset_libraries:
.. index:: Asset Library Extensions

***************
Asset Libraries
***************

An *Asset Library* extension adds a :ref:`Remote Asset Library <asset_libraries-remote>`
to the :ref:`Asset Libraries <prefs-asset-libraries>` preferences when installed.

The extension is simply a manifest referencing the URL of the remote-asset-library.

.. note::

   The following steps assume the remote-asset-library is already hosted,
   see `Hosting the Asset Library`_.


Creating an Asset Library Extension
===================================

An extension is defined by a :ref:`blender_manifest.toml <extensions-manifest>`,
which Blender builds into a ZIP file for re-distribution.


Manifest
--------

Values shared by all extensions (``id``, ``version``, ``license``, etc.)
are described in the :ref:`manifest <extensions-manifest>` reference.

A minimal manifest for an asset-library-extension:

.. code-block:: toml

   schema_version = "1.0.0"

   id = "my_assets"
   version = "1.0.0"
   # Used as the library name in the preferences.
   name = "My Assets"
   tagline = "Materials for architectural visualization"
   maintainer = "Your Name"
   type = "asset-library"

   # Older versions don't support asset-library-extensions.
   blender_version_min = "5.3.0"

   license = [
     "SPDX:CC0-1.0",
   ]

   [asset_library]
   remote_url = "https://example.com/my-assets/"

Permissions
   Asset libraries only support the ``scripts`` permission,
   declare it when assets run Python scripts (Python drivers for example).

   .. code-block:: toml

      [permissions]
      scripts = "Rig controls use Python drivers"

   - The value is a short reason why scripts are needed, as with add-on permissions.
   - It's shown in the extension details, so users know before installing.
   - It's intended for hosting services, which may validate assets that run scripts,
     Blender doesn't enforce it.

Authentication
   This section can be skipped unless you intend to restrict access to the library using access tokens.

   Declare an ``[asset_library.auth]`` table when the library accepts an access token.

   .. code-block:: toml

      [asset_library.auth]
      required = false
      auth_method = "TOKEN"

   - ``required``: set to ``true`` when the library can't be used without a token.
     Currently this is informative, Blender doesn't check it.
   - ``auth_method``: only ``"TOKEN"`` is supported,
     the same bearer token used by :ref:`extension repositories <access-token>`.

   Without this table, the library won't receive the repository's access token (see `Access Token`_).


Access Token
------------

Which token an asset library uses is set by the extension repository, not the manifest.

Library Access Token
   Each library has its own :ref:`access token <asset-library-access-token>`,
   entered in the library's settings in the :ref:`Asset Libraries <prefs-asset-libraries>` preferences.
   This is the default.

   Use this when the assets are hosted separately from the extension repository,
   so the library's service manages its own tokens.

Repository Access Token
   The asset library simply uses the extension repository's access token,
   so users only need to enter the token once.

   This is useful when the repository & the assets are hosted by the same service,
   it applies to all of the repository's asset libraries that declare ``[asset_library.auth]``.

   Static repositories enable this using ``--assetlib-auth-method=FROM_REPOSITORY``,
   see :ref:`server-generate <command-line-args-extension-server-generate>`.


Building
--------

The extension only contains the manifest:

.. code-block:: text

   my_assets/
   └─ blender_manifest.toml

Build from the directory containing the manifest:

.. code-block:: sh

   cd my_assets
   blender --command extension build

This creates ``{id}-{version}.zip``, ready to install or publish.

Building checks the asset library values,
so mistakes are reported before the extension is shared, e.g.:

- A missing ``[asset_library]`` table.
- A ``remote_url`` that doesn't start with ``http://`` or ``https://``.
- Permissions other than ``scripts``.

See :ref:`build <command-line-args-extension-build>`.


Publishing
----------

The ZIP is published the same as any other extension:

- Shared directly, users install it by dragging the ZIP into Blender.
- Hosted on an :doc:`extension repository </advanced/extensions/creating_repository/index>`,
  users install it from :menuselection:`Preferences --> Get Extensions`.

.. note::

   At the time of writing, the `Blender Extensions Platform <https://extensions.blender.org>`__
   doesn't host asset-library-extensions (support is planned),
   use your own repository or share the ZIP directly.


Releasing Updates
-----------------

.. NOTE(@ideasman42): while changing the URL works,
   the existing cache is *not* deleted, so this isn't ideal.

Updating the assets isn't managed via the extension,
it's done on the server by updating the files & re-generating the listing.

- Blender re-downloads the listing periodically.
- Users can also :ref:`Refresh Remote Listing <bpy.ops.asset.library_reload_listing>`.

Releasing a new version of the extension only makes sense when its metadata changes.


Hosting the Asset Library
=========================

.. NOTE(@ideasman42): that the purpose of this page isn't to setup complex web hosting.
   Although, we could link to hosting at some point.

An asset-library-extension just needs a generated listing and a URL to point to,
this section covers the minimum to set these up, including testing locally.

A remote-asset-library is a directory of blend-files along with a listing (JSON files)
describing the assets it contains.

- For making assets see :ref:`Creating an Asset <asset-create>`.
- For the requirements of remote-asset-libraries
  see :ref:`Remote Asset Libraries <asset_libraries-remote>`.

Generate the listing & edit ``_asset-library-meta.json``,
see :ref:`Creating a Remote Asset Library <asset-library-creating>`.
It's best to use the same name as the extension.

To test your remote-asset-library as an extension:

#. Serve the library directory, see :ref:`Serving a Remote Asset Library <asset-library-serving>`.
#. Set ``remote_url = "http://127.0.0.1:8000/"`` in the manifest & build the extension.
#. Drag & drop the ZIP into Blender, this installs the extension & enables the library.
#. Check the assets show in the Asset Browser.

.. note::

   :ref:`Online Access <bpy.types.PreferencesSystem.use_online_access>` must be enabled,
   even when the server runs on your own computer.

To publish, upload the same directory to a web server
that meets the :ref:`requirements <asset-library-server-requirements>`,
then rebuild the extension with its URL, so the library no longer points to ``127.0.0.1``.


Limitations
===========

- Each extension defines a single asset library.
- Assets can't be bundled with extensions, they're always downloaded from the server.
