# Nestjs-Better-Auth-Flutter-Starter (archived)

This starter moved. It is now the **mobile App** of rok-data's monorepo
template, and that copy is the only one kept up to date:

- Source: [`crates/rok-templates/templates/monorepo/apps/mobile/`](https://github.com/ateeq1999/rok-data/tree/main/crates/rok-templates/templates/monorepo/apps/mobile)
  in [ateeq1999/rok-data](https://github.com/ateeq1999/rok-data) (the
  `rok-templates` crate).
- Guide: [The monorepo template](https://github.com/ateeq1999/rok-data/blob/main/crates/rok-templates/docs/guide/monorepo.md).

Start a project with it:

    cargo install rok-data-cli
    rok init my-app --template monorepo --org com.example

`--org` and the project's name set the package name, the Android
`applicationId`, the iOS bundle id, the deep-link scheme and the display
name.

What changed on the way: the App talks to rok-data's axum API (`apps/api`)
instead of a NestJS / Better Auth backend, through the generated Dart
client (`clients/dart`), which `rok gen` keeps in step with the API. The
features that API does not serve yet (organizations, magic-link sign-in,
the admin panel, deleting the account, OAuth sign-in) are not in the App.
Push notifications (FCM) are a written recipe:
[Push notifications](https://github.com/ateeq1999/rok-data/blob/main/crates/rok-templates/docs/guide/recipes/push-notifications.md).
The Firebase configuration this repository held is not carried over.

This repository is archived and read-only. Open issues and pull requests
against [ateeq1999/rok-data](https://github.com/ateeq1999/rok-data).
