#!/bin/bash

installBlockEx () {
    echo "Installing Block Explorer"
    git clone https://github.com/ProjectArdvark/block-explorer.git /home/gamefrag/block-explorer
    cd /home/gamefrag/block-explorer
    yarn install
        sudo chown -R gamefrag:gamefrag /home/gamefrag/.config
        mongo fragexplorer --eval "db.createUser( { user: \"fragblockexplorer\", pwd: \"fragblockexplorerpassword\", roles: [ \"readWrite\" ] } )"
    cat > /home/gamefrag/block-explorer/config.server.js << EOL
/**
 * Keep all your API & secrets here. DO NOT IMPORT THIS FILE IN /client folder
 */
const secretsConfig = {
  db: {
    host: '127.0.0.1',
    port: '27017',
    name: 'fragexplorer',
    user: 'fragblockexplorer',
    pass: 'fragblockexplorerpassword'
  },
  rpc: {
    host: '10.36.12.4',
    port: '42021',
    user: 'fragblockexplorer',
    pass: 'fragblockexplorerpass',
    timeout: 8000, // 8 seconds
  },
}

module.exports = { secretsConfig }; // This is returned as an object on purpose so you have to be explicit at stating that you are accessing a secrets config
EOL
    cat > /home/gamefrag/block-explorer/config.js << EOL
const { SocialType } = require('./features/social/data');

/**
 * Global configuration object.
 *
 * Running:
 * yarn run start:api
 * yarn run start:web (Access project via http://localhost:8081/) (port comes from webpack.config.js)
 *
 * For nginx server installation and production read /script/install.sh `installNginx ()`. Note that we use Certbot to grant SSL certificate.
 *
 */
const config = {
  api: {
    host: 'http://localhost', // ex: 'https://explorer.game-frag.com' for nginx (SSL), 'http://IP_AD
    port: '3000', // ex: Port 3000 on prod and localhost
    portWorker: '3000', // ex: Port 443 for production(ngingx) if you have SSL (we use certbot), 300
    prefix: '/api',
    timeout: '5s'
  },
  coinDetails: {
    name: 'Game-Frag',
    shortName: 'FRAG',
    displayDecimals: 2,
    longName: 'Game-Frag Cryptocurrency',
    coinNumberFormat: '0,0.0000',
    coinTooltipNumberFormat: '0,0.0000000000', // Hovering over a number will show a larger percisio
    websiteUrl: 'https://www.game-frag.com/',
    masternodeCollateral: 250000 // MN ROI% gets based on this number. If your coin has multi-tiered
  },
  offChainSignOn: {
    enabled: true,
    signMessagePrefix: 'MYCOINSIGN-' // Unique prefix in "Message To Sign" for Off-Chain Sign On
  },

  // Add any important block counting down in this array
  blockCountdowns: [
    {
      block: 300153, // What block are we counting down to?
      beforeTitle: 'Next Phase', // What do we show before the block number is hit?
      afterTitle: 'Phase Active For' // What do we show after the block number is hit?
    }
  ],


  /**
   * API & Social configurations
   */

  /**
   * Social integrations are all aggregated into a single table & common format. For example, you can have mulitple reddit integrations with different flairs.
   */
  social: [
    {
      name: 'developmentUpdates', // Unique name of the social widget
      type: SocialType.Reddit, // What type of social widget is it?
      group: 'community', // Multiple social widget feeds can be combined into a single cross-app group feed
      options: {
        subreddit: 'MyAwesomeCoin', // Coin as an example
        query: 'flair:"Community"' // Show only posts with Community flair (the little tag next to post) (You can empty this to show all posts or specify your own filter based on https://www.reddit.com/wiki/search)
      }
    }
  ],
 freegeoip: {
    api: 'https://extreme-ip-lookup.com/json/' //@todo need to find new geoip service as the limits are too small now (hitting limits)
  },
  coinMarketCap: {
    api: 'https://api.coingecko.com/api/v3/coins/',
    ticker: 'game-frag'
  },

  /**
   * Explorer Customization
   */
  desktopMenuExpanded: true,        // If set to true the website will have opened navigation bar on load

  /**
   * Community & Address Related
   */
  community: {
    // If you comment out all of these addresses the 'Community Addresses' section will not show up on the homepage. You can add as many addresses to highlight as you wish.
    highlightedAddresses: [
      //{ label: 'Community Donations', address: 'XXXXXXXXXXXXXXXXXXXXXXXXXXX' }, // Uncomment and replace with your coin address to highlight an address
      //{ label: 'Community Funding', address: 'XXXXXXXXXXXXXXXXXXXXXXXXXXX' }, // Uncomment and replace with your coin address to highlight any other address
    ],

    // It's hard to identify governance vs mn rewards in Dash. Add any governance addresses here, any masternode rewards into these addresses will count as governance reward instead of MN rewards
    governanceAddresses: [
      /**
       * If you have governance voting in your coin you can add the voting addresses to below.
       * This is only requried because governance rewards are simply replacing MN block reward (so they are identical on the blockchain)
       */
      /*
      // 72000 FRAG 159ff849ae833c3abd05a7b36c5ecc7c4a808a8f1ef292dad0b02875009e009e
      "bZ1HJB1kEb1KFcVA42viGJPM7896rsRp9x",
      // 72000 FRAG d35ed6e32886c108165c50235225da29ea3432404a4578831a8120b803e23f3d
      "bSP75eHtokmNq5n8iDVLbZVKuLAi8rN1KM",
      // 70000 FRAG 5b3b0eec9271297a37c97fca1ecd98e033ea3813d8669346bfac0f08aa3142f8
      "bQockBvNDLUJ4zFV3g2EsymfuVxduWPpmA",
      // 45000 FRAG 6a9fbf985e8d1737c3282d34759748ca02ab9c7893bd6d24dd5d72db66325707
      // 37000 FRAG 3c1f46128606ddca07a4691f8697974c8789ca365c6f3ac8e7d866740450cb59
      "bR1Qa5HjuU8bN3J2WqrM2FSWzmk7RPyujp",
      // 25000 FRAG 8ab5e85f2863afa1fdab187a2747d492a0d2a3903038063dbd5e187a76efdb03
      // 25000 FRAG 98d82c3e6fd371daeaee45ed56875c413c5a6f596571fdb8888e8bf23b3e530c
      "bUagNLYEPmDTbnr7QgqFJidnASxvjNp2Kh",
      // 20000 FRAG c86852e84b0c8d31af953ad75c42a6f581f8f2bb6f8835e7e9080694f92151c8
      // 20000 FRAG 78bb316c7d66067df8d279a74c619aaac4b5412066ef0b87b9b6765960895ade
      // 50 FRAG 22bc15f46408eeafe4b2ac6f54ddbb9c3b277848a44ae4db2da7100dda2da1ec
      "bVnzUZen6Sn473trmkd5vJ3zVMW8HwtnT9",
      // 16500 FRAG 2fc3878768ff97cb67d8336a7e6fef50dab71696f9c5fe33d4b6226468609efe
      // 16500 FRAG 9f011213e8b6890ab1ec66f037f1e16f3c8c138289877e0572b498aef31b3020
      // 16500 FRAG ac562d3f239b2896d293b3126e83bbf6bef618ce59194657668b1b049dd094ad
      "bTHnr8H5anfhsx222Q5jgE3JjFog7pk5Cd"
      */
    ]
  },
 // Each address can contain it's own set of widgets and configs for those widgets
  addressWidgets: {
    'XXXXXXXXXXXXXXXXXXXXXXXXXXX': {
      // WIDGET: Adds a list of masternodes when viewing address. We use this to show community-ran masternodes
      masternodesAddressWidget: {
        title: 'Community Masternodes',
        description: 'Profits from these masternodes fund & fuel community talent',
        isPaginationEnabled: false, // If you have more than 10 you should enable this
        addresses: [
          'XXXXXXXXXXXXXXXXXXXXXXXXXXX',
          'XXXXXXXXXXXXXXXXXXXXXXXXXXX',
          'XXXXXXXXXXXXXXXXXXXXXXXXXXX',
        ]
      }
    },
    'FEE': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Transaction Fee âŒš',
        title: 'A small portion of a transaction will be sent to this address. Referred to as "Transaction Fee".'
      }
    },
    'COINBASE': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Coinbase (Premine & POW) ðŸ’Ž',
        title: 'This address was active during Proof Of Work (POW) phase to distribute rewards to miners & masternode owners.'
      }
    },
    'MN': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Masternode Rewards ðŸ’Ž',
        title: 'Each block contains a small portion that is awarded to masternode operators that lock 5000 FRAG. Masternodes contribute to the network by handling certain coin operations within the network.'
      }
    },
    'POW': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Proof Of Work Rewards ðŸ’Ž',
        title: 'Game-Frag started as a Proof Of Work & Masternode coin. Blocks would be mined by powerful computers and be rewarded for keeping up the network.'
      }
    },
    'POS': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Proof Of Stake Rewards ðŸ’Ž',
        title: 'Inputs that are over 100 FRAG can participate in network upkeep. Each block (~90 seconds) one of these inputs is rewarded for keeping up the network.'
      }
    },
  },
 ///////////////////////////////
  // Adjustable POS Profitability Score - How profitable is your staking, tailored for your blockchain
  ///////////////////////////////
  profitabilityScore: {
    scoreStyles: [
      // Best case
      {
        color: '#72f87b',
        title: 'Rank 1/10 - Excellent!!!'
      },
      {
        color: '#84f771',
        title: 'Rank 2/10 - Excellent!'
      },
      {
        color: '#a0f771',
        title: 'Rank 3/10 - Excellent'
      },
      {
        color: '#bcf671',
        title: 'Rank 4/10 - Very Good'
      },
      {
        color: '#d8f671',
        title: 'Rank 5/10 - Above Average'
      },
      {
        color: '#f3f671',
        title: 'Rank 6/10 - Average'
      },
      {
        color: '#f5dc71',
        title: 'Rank 7/10 - Below Average'
      },
      {
        color: '#f5c071',
        title: 'Rank 8/10 - Not Optimal'
      },
      {
        color: '#f4a471',
        title: 'Rank 9/10 - Not Optimal!'
      },
      // Worst case (default)
      {
        color: '#f48871',
        title: 'Rank 10/10 - Not Optimal!!!'
      }
    ]
  },

  ///////////////////////////////
  /// Cron & Syncing
  ///////////////////////////////
  blockConfirmations: 50,           // We will re-check block "merkleroot" this many blocks back. If they differ we will then start unwinding carver movements one block at a time until correct block is found. (This is like min confirmations)
  verboseCron: true,                // If set to true there are extra logging details in cron scripts
  verboseCronTx: false,             // If set to true there are extra tx logging details in cron scripts (Not recommended)
  blockSyncAddressCacheLimit: 50000 // How many addresses to keep in memory during block syncing (When this number is reached the entire cache is flushed and filled again from beginning)
};
# Setup
echo "Updating system..."
sudo apt-get update -y
sudo apt-get install -y apt-transport-https build-essential cron curl gcc git g++ make sudo vim wget
clear

# Variables
echo "Setting up variables..."
fraglink=`curl -s https://api.github.com/repos/ProjectArdvark/block-explorer/releases/latest | grep browser_download_url | grep linux64 | cut -d '"' -f 4`
rpcuser=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
rpcpassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')
echo "Repo: $fraglink"
echo "PWD: $PWD"
echo "User: $rpcuser"
echo "Pass: $rpcpassword"
sleep 5s

# Check for blockex folder, if found then update, else install.
if [ ! -d "/home/gamefrag/block-explorer" ]
then
    installBlockEx
    echo "Finished installation!"
else
    cd /home/gamefrag/block-explorer
    git pull
    echo "BlockEx updated!"
fi