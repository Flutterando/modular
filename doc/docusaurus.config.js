const {themes} = require('prism-react-renderer');
const lightCodeTheme = themes.github;
const darkCodeTheme = themes.dracula;

// With JSDoc @type annotations, IDEs can provide config autocompletion
/** @type {import('@docusaurus/types').DocusaurusConfig} */
(module.exports = {
  title: 'Modular',
  tagline: 'A smart project structure',
  url: 'https://modular.flutterando.com.br',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  markdown: {
    // Parse .md as CommonMark (so `<...>`/`{...}` in prose are literal — the
    // legacy reference pages are full of Dart generics); use .mdx for JSX.
    format: 'detect',
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },
  favicon: 'img/favicon.svg',
  organizationName: 'flutterando', // Usually your GitHub org/user name.
  projectName: 'modular', // Usually your repo name.

  // Brand fonts: Space Grotesk (display), Inter (body), JetBrains Mono (technical).
  headTags: [
    {
      tagName: 'link',
      attributes: {rel: 'preconnect', href: 'https://fonts.googleapis.com'},
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'preconnect',
        href: 'https://fonts.gstatic.com',
        crossorigin: 'anonymous',
      },
    },
  ],
  stylesheets: [
    'https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap',
  ],

  presets: [
    [
      '@docusaurus/preset-classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          editUrl: 'https://github.com/Flutterando/modular/tree/master/doc',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        title: 'Modular',
        logo: {
          alt: 'Modular Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'doc',
            docId: 'intro',
            position: 'left',
            label: 'Getting Started',
          },
          {
            href: 'https://github.com/Flutterando/modular',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Getting Started',
                to: '/docs/intro',
              },
              {
                label: 'flutter_modular',
                to: '/docs/flutter_modular/start',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Telegram',
                href: 'https://t.me/flutterando',
              },
              {
                label: 'Discord',
                href: 'https://discord.com/invite/x7X4uA9',
              },
              {
                label: 'Facebook',
                href: 'https://www.facebook.com/groups/flutterando',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'Flutterando',
                href: 'https://flutterando.com.br',
              },
              {
                label: 'Medium Flutterando',
                href: 'https://medium.com/flutterando',
              },
              {
                label: 'GitHub',
                href: 'https://github.com/Flutterando/modular',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Flutterando, Inc. Built with Docusaurus.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
        additionalLanguages: ['dart', 'yaml'],
      },
    }),
});
