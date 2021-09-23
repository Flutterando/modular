const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

// With JSDoc @type annotations, IDEs can provide config autocompletion
/** @type {import('@docusaurus/types').DocusaurusConfig} */
(module.exports = {
  title: 'Modular',
  tagline: 'A smart project structure',
  url: 'https://your-docusaurus-test-site.com',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',
  organizationName: 'flutterando', // Usually your GitHub org/user name.
  projectName: 'modular', // Usually your repo name.

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
          src: 'img/logo.png',
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
              {
                label: 'shelf_modular',
                to: '/docs/shelf_modular/start',
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
