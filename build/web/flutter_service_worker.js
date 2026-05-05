'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "ace026ea60b0aad3d6fbf8add1817ece",
"assets/AssetManifest.bin.json": "9ed1781e118c4b5623c93a1f156ac36b",
"assets/AssetManifest.json": "bc15ebb3f27ab84b8e1f091cd95c6a9c",
"assets/assets/fonts/DejaVuSans-Bold.ttf": "132839e7a052c2bc6771b6818aad85bd",
"assets/assets/fonts/DejaVuSans.ttf": "be189a7e2711cdf2a7f6275c60cbc7e2",
"assets/assets/fonts/MaterialIcons-Regular.otf": "f82fca9c45704fcf5c2978f473f53270",
"assets/assets/fonts/NotoSans-Bold.ttf": "a165a42685795361b25593effb32fdb1",
"assets/assets/fonts/NotoSans-Regular.ttf": "2fd9c16b805724d590c0cff96da070a4",
"assets/assets/fonts/Poppins-Bold.ttf": "08c20a487911694291bd8c5de41315ad",
"assets/assets/fonts/Poppins-Regular.ttf": "093ee89be9ede30383f39a899c485a82",
"assets/assets/fonts/Roboto-Bold.ttf": "36b5bab58a18b9c924861a4ccbf1a790",
"assets/assets/fonts/Roboto-Italic.ttf": "93b13a58dedeebe519846555a543523b",
"assets/assets/fonts/Roboto-Regular.ttf": "5673da52c98bb6cb33ada5aaf649703e",
"assets/assets/icons/add.png": "737ec290471f789e58b8e1e10cd45789",
"assets/assets/icons/add_addon.png": "380f85d465698518dc2cb708e93c3cd5",
"assets/assets/icons/add_box.png": "45969cd2d9638d06128836392055292a",
"assets/assets/icons/add_ingredient.png": "fa718df088346fafae93288f00593549",
"assets/assets/icons/add_stock.png": "380f85d465698518dc2cb708e93c3cd5",
"assets/assets/icons/cart.png": "000f4a1f8ec93e24f1f30f3f42d48053",
"assets/assets/icons/clock.png": "724eede54e79ab4c12fbfb5be60bb572",
"assets/assets/icons/collapse.png": "091e0c3b1c393a1d9340dfcaa9073d0b",
"assets/assets/icons/delivery.png": "9f8dbd6f85a9d54a4d6825be207f48e2",
"assets/assets/icons/edit_restock.png": "7853368b97810098de7db9e149a43218",
"assets/assets/icons/enter.png": "14b4fbc07f06e1e59c4c8204b4cd0709",
"assets/assets/icons/expand.png": "39ea3c0f4a6ceb5fa6b94d36372fc1fa",
"assets/assets/icons/facebook.png": "ad56565a45e2dc6b77cfff4e48176666",
"assets/assets/icons/healthy.png": "03d7a123d2d0350f3432062ed423d684",
"assets/assets/icons/instagram.png": "0d392c1021d421c2678c59d8fd1b46a7",
"assets/assets/icons/location.png": "13d3b1917232d712a90b5d1465f4d1b2",
"assets/assets/icons/minus.png": "4fab88200c9070f61dce2f60d1c763f4",
"assets/assets/icons/orders.png": "9dc00abc2a785175de40d6aeb3aa12e2",
"assets/assets/icons/phone.png": "2eb25a8c5e21f6c6551bb86ecac9045b",
"assets/assets/icons/plus.png": "327f4df4ce2592b620a2b573a631311e",
"assets/assets/icons/print.png": "409930a4505af0ca590fb2517c481111",
"assets/assets/icons/recipe.png": "5d60263c3231bbaab75954ea74361b9e",
"assets/assets/icons/refresh.png": "ca988f3f88c86d4621213af8c46bb961",
"assets/assets/icons/settings.png": "890d3b81c94db103d8c2996c8f0124bd",
"assets/assets/icons/twitter.png": "f23f92313ec553926581f36f8da6135b",
"assets/assets/images/add.png": "58267eb3bed1220541b6dcffe2cad1d3",
"assets/assets/images/admin.png": "fa50f5aec28240c5a0555db89ea24e49",
"assets/assets/images/admin1.png": "10e0e5926af319d1212bd3382a7adf9b",
"assets/assets/images/admin2.png": "af3b6a87e05a89f85eef6d6ba9d8a536",
"assets/assets/images/backgroundhome.png": "1f5a50c4395795e403e88a23beaf0d79",
"assets/assets/images/beef%2520chessy%2520mushroom.jpg": "9f5ccfae2f170703d613f4c593826079",
"assets/assets/images/beef%2520olive.jpg": "ef0de66f2796795d42c2b01f6173c677",
"assets/assets/images/beef%2520tomato.jpg": "ef80e285955dce09a5283c08a2288b5a",
"assets/assets/images/bg_1.png": "9b21cd488b7dedd732905bbd8c1156ef",
"assets/assets/images/bg_4.png": "a3e91dc1f36fd3d6dccfb3f6917a6636",
"assets/assets/images/bg_5.png": "71e80b360f1f1a2d1190765eac6bfe2f",
"assets/assets/images/chalkart.png": "7032f7e6620cd67f8b783b55bc85aed5",
"assets/assets/images/check%2520(1).png": "0a4b0bf72fba4d6dcaf6e1b5905d948a",
"assets/assets/images/check.png": "cccfd93faea29ddafd9a0c4ad4a3b0f3",
"assets/assets/images/checklist.png": "f4cd2a08c62d64a5754982f3db53e205",
"assets/assets/images/cheezy%2520pizza.jpg": "8f76ef6a0946c2fbb64dbf3367b64715",
"assets/assets/images/clock.png": "724eede54e79ab4c12fbfb5be60bb572",
"assets/assets/images/dashboard.png": "4cee2121c36013527f60f55994b1e679",
"assets/assets/images/dashboard1.png": "f60eeb21f0addae76fe8055f926701c0",
"assets/assets/images/exit.png": "dc7e4b4d1c5c8d673d755ca88343e9bc",
"assets/assets/images/expenses.png": "feb60dcd336a0e249dfc73bd3e52e2d0",
"assets/assets/images/facebook.png": "ad56565a45e2dc6b77cfff4e48176666",
"assets/assets/images/fireandflavor.png": "307a25febb120effc495671011f5a70e",
"assets/assets/images/food.png": "6f044c0aa80dc11e464fe2efd771e07f",
"assets/assets/images/fxsound_setup.exe": "f71b0995d8c897e089571ab0ab219395",
"assets/assets/images/gensan%2520seafood.jpg": "9fd616542da95fe623ea9b81da77f090",
"assets/assets/images/hawaiian.jpg": "7b3661133e15d93c2a2a275ffd59c57e",
"assets/assets/images/home.png": "3b26fe628b2286540a71da46deb5ceb8",
"assets/assets/images/home3.png": "38e16e1ac521181f8deec745eaa8e747",
"assets/assets/images/id-card.png": "a6ff227b1f09c491f13f4439ff7b3d56",
"assets/assets/images/instagram.png": "0d392c1021d421c2678c59d8fd1b46a7",
"assets/assets/images/inventory.png": "2933d7bc6a189e7a44fb867ffb632474",
"assets/assets/images/location-pin.png": "13d3b1917232d712a90b5d1465f4d1b2",
"assets/assets/images/lock%2520(2).png": "690a54de56f872e15aa81fad14e02905",
"assets/assets/images/lock.png": "01eca79a9a8efc4502abd9a2ea2f1e04",
"assets/assets/images/loginbackground.jpg": "6ad53537a9fa01f4f5bfe99738c81fc2",
"assets/assets/images/logo.png": "307a25febb120effc495671011f5a70e",
"assets/assets/images/logout.png": "fad1cd1d0283bd1fcdf235c8a72f7065",
"assets/assets/images/logout2.png": "9973c8071a65dae2724febd2449556c1",
"assets/assets/images/logout4.png": "96daff42d31f15304287ae7afd26cb9d",
"assets/assets/images/manager.png": "f928ef8a07454bcc52742941cbb062d8",
"assets/assets/images/manager1.png": "e17b3a27d81349a892a3dfc674331aab",
"assets/assets/images/manager3.png": "11b71e45dab8bcd915e2ed1d8992e16e",
"assets/assets/images/menu.png": "9eac78330a9487b878afbcb287565c96",
"assets/assets/images/menu1.png": "5898016dbe4d62f6a8352cd444b9d211",
"assets/assets/images/notification.png": "647ba397be45bb84bad1283a25b63463",
"assets/assets/images/output-onlinepngtools%2520(4).png": "f928ef8a07454bcc52742941cbb062d8",
"assets/assets/images/paper.png": "5791b2ee8206a276fd2ded46723bce00",
"assets/assets/images/people%2520(2).png": "811302371c201d07ccb6b0672d1a9e06",
"assets/assets/images/people.png": "811302371c201d07ccb6b0672d1a9e06",
"assets/assets/images/pepperoni.jpg": "7c2715d699163aba34d23afaa2999efa",
"assets/assets/images/phone-call.png": "2eb25a8c5e21f6c6551bb86ecac9045b",
"assets/assets/images/pie-chart.png": "dcde9b4e9d88c541e3b73a5bb585b415",
"assets/assets/images/pizza.png": "242e163ebdad0d03407d5ff2726fdb90",
"assets/assets/images/pizza2.png": "094527be68026e95e5a960f34ee32085",
"assets/assets/images/pizza4.png": "b05a72f4367c284b4c392360a82751fd",
"assets/assets/images/print.png": "409930a4505af0ca590fb2517c481111",
"assets/assets/images/RemoteMouse.exe": "a3a99e5e081a69797dc9b8e0857360b5",
"assets/assets/images/sales.png": "b4e152f0092b0a11b65f3e3b39abaa6d",
"assets/assets/images/spicy%2520italian.jpg": "cb8b93124326d80e4f17a2edace71fbd",
"assets/assets/images/task.png": "9402ebc40127a7a0218766dec9993ef8",
"assets/assets/images/task1.png": "5ac52823a3aa29f7524bfb2c4e079b77",
"assets/assets/images/task2.png": "2a6b61bf4936f24fb78ae4c5cf77e342",
"assets/assets/images/twitter.png": "f23f92313ec553926581f36f8da6135b",
"assets/assets/images/vouchers.png": "3a302b2c5f8101016402c6965a500e3e",
"assets/assets/images/wmremove-transformed.png": "6f044c0aa80dc11e464fe2efd771e07f",
"assets/FontManifest.json": "c62ca1150d5112036626cfbfb0bfedbe",
"assets/fonts/MaterialIcons-Regular.otf": "b026f3e98e5e7d13d72aee1880fc7825",
"assets/NOTICES": "5317cbffcab82292d78522e1f8e909a2",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "15d54d142da2f2d6f2e90ed1d55121af",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "262525e2081311609d1fdab966c82bfc",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "269f971cec0d5dc864fe9ae080b19e23",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "d7616055b1c168a8790e4970af53f870",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "7afb6854083eaab55f7bc079afe40238",
"/": "7afb6854083eaab55f7bc079afe40238",
"main.dart.js": "acd97880267095b5bd65911c51c42bd4",
"manifest.json": "bd080ce8fda68fd9ee20ac8a99834ed2",
"version.json": "16862e426a9c714bccaf16fa5589b80f"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
