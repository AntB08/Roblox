.. _extensions-create_repo-dynamic:

****************************************
Creating a Dynamic Extensions Repository
****************************************

A dynamic repository allows you to serve a smaller JSON file with only the latest version
of the extensions which are compatible with the query parameters.
This is only relevant for repositories which contain multiple version of multiple extensions.

For small or personal repositories it is simpler and recommended to use
:doc:`static repositories <static_repository>` instead.

Listing
=======

To setup a dynamic extensions repository, follow the steps for :doc:`static repositories <static_repository>`,
since the format and the listing are the same.

Query Parameters
================

When Blender fetches the extensions listing it passes the following arguments to make sure only
compatible extensions are listed:

- ``platform``
- ``blender_version``

These arguments are passed as parameters to the server via a query URL:

   :URL: ``https://extensions.blender.org/api/v1/extensions/``
   :query URL: ``https://extensions.blender.org/api/v1/extensions/?blender_version=4.2.0&platform=linux-x64``


.. _access-token:

Access Token
============

Some repositories may require authentication. The user can specify an ``access token`` for a repository,
which is passed along with the API request from Blender.

This is passed to the servers via an Authorization header:

.. code-block:: sh

   curl -i https://extensions.blender.org/api/v1/extensions/ \
        -H "Accept: application/json" \
        -H "Authorization: Bearer abc29832befb92983423abcaef93001"


Asset Libraries
---------------

A repository can share its access token with the
:ref:`asset library extensions <extensions-asset_libraries>` it lists,
using the optional ``assetlib_auth_method`` in the listing:

``PER_LIBRARY``
   Each asset library uses its own access token, edited in the
   :ref:`Asset Libraries preferences <prefs-asset-libraries>` (the default, used when omitted).

   Suits asset libraries hosted by different providers.
``FROM_REPOSITORY``
   Asset libraries use the repository's access token, edited in the
   :ref:`extension repository's preferences <prefs-extensions-repositories>`.

   Suits asset libraries accessed with the same account.

.. code-block:: json

   {
      "version": "v1",
      "blocklist": [],
      "assetlib_auth_method": "FROM_REPOSITORY",
      "data": []
   }

This only applies to asset libraries which support authentication,
declared by ``[asset_library.auth]`` in their manifest.
