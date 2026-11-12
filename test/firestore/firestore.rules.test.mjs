
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import { fileURLToPath } from 'node:url';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';

import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  GeoPoint,
  Timestamp,
} from 'firebase/firestore';

// Test dosyasından proje kökünü bul.
const rulesFile = fileURLToPath(
  new URL('../../firestore.rules', import.meta.url),
);

const rules = readFileSync(rulesFile, 'utf8');

// Gerçek Firebase projesini kullanmıyoruz.
const PROJECT_ID = 'demo-afetnet-security-tests';

let env;

function dbAs(uid) {
  return env.authenticatedContext(uid).firestore();
}

function guestDb() {
  return env.unauthenticatedContext().firestore();
}

function reference(db, path) {
  return doc(db, path);
}

function testUser(role, isVerified = false) {
  return {
    fullName: 'Demo Kullanıcı',
    role,
    isVerified,
    notificationsOptIn: true,
    consents: {
      privacyVersion: '1.0',
      kvkkVersion: '1.0',
      acceptedAt: Timestamp.now(),
    },
    createdAt: Timestamp.now(),
  };
}

function inventoryItem(quantity = 150) {
  return {
    name: 'İçme Suyu',
    category: 'water',
    unit: 'adet',
    quantity,
    targetLevel: 200,
    criticalLevel: 30,
    updatedAt: Timestamp.now(),
  };
}

function assignment(status = 'assigned') {
  return {
    incidentId: 'incident_01',
    teamId: 'team_04',
    status,
    assignedBy: 'official_01',
    updatedBy: 'official_01',
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  };
}

function helpRequest(priority = 1) {
  return {
    createdBy: 'citizen_01',
    type: 'debris',
    priority,
    status: 'pending',
    peopleCount: 2,
    addressText: 'Demo adres',
    description: 'Demo yardım çağrısı',
    location: new GeoPoint(36.2, 36.16),
    geohash: 'sy8p0000',
    photoUrls: [],
    createdAt: Timestamp.now(),
  };
}

async function seedTestData() {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await Promise.all([
      setDoc(
        reference(db, 'users/citizen_01'),
        testUser('citizen'),
      ),
      setDoc(
        reference(db, 'users/citizen_02'),
        testUser('citizen'),
      ),
      setDoc(
        reference(db, 'users/official_01'),
        testUser('official', true),
      ),
      setDoc(
        reference(db, 'users/official_pending'),
        testUser('official', false),
      ),
      setDoc(
        reference(db, 'users/citizen_02/private/contact'),
        {
          phone: '05000000000',
          medical: {
            bloodType: 'A+',
          },
        },
      ),
      setDoc(
        reference(db, 'warehouses/demo_depo'),
        {
          name: 'Demo Deposu',
          locationText: 'Antakya',
          isDemo: true,
        },
      ),
      setDoc(
        reference(
          db,
          'warehouses/demo_depo/inventory/water',
        ),
        inventoryItem(),
      ),
      setDoc(
        reference(db, 'assignments/assignment_01'),
        assignment(),
      ),
    ]);
  });
}

describe('AfetNet Firestore Security Rules', () => {
  before(async () => {
    env = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        host: '127.0.0.1',
        port: 8080,
        rules,
      },
    });
  });

  beforeEach(async () => {
    await env.clearFirestore();
    await seedTestData();
  });

  after(async () => {
    if (env) {
      await env.cleanup();
    }
  });

  // --------------------------------
  // 1. Kimlik doğrulama
  // --------------------------------

  it('Giriş yapmamış kullanıcı depo okuyamaz', async () => {
    const db = guestDb();

    await assertFails(
      getDoc(reference(db, 'warehouses/demo_depo')),
    );
  });

  it('Afetzede kendi profilini okuyabilir', async () => {
    const db = dbAs('citizen_01');

    await assertSucceeds(
      getDoc(reference(db, 'users/citizen_01')),
    );
  });

  // --------------------------------
  // 2. Kişisel veri güvenliği
  // --------------------------------

  it('Afetzede başka kullanıcının tıbbi verisini okuyamaz', async () => {
    const db = dbAs('citizen_01');

    await assertFails(
      getDoc(
        reference(
          db,
          'users/citizen_02/private/contact',
        ),
      ),
    );
  });

  it('Onaylı yetkili özel iletişim bilgisini okuyabilir', async () => {
    const db = dbAs('official_01');

    await assertSucceeds(
      getDoc(
        reference(
          db,
          'users/citizen_02/private/contact',
        ),
      ),
    );
  });

  // --------------------------------
  // 3. Rol yükseltme saldırısı
  // --------------------------------

  it('Afetzede kendi rolünü official yapamaz', async () => {
    const db = dbAs('citizen_01');

    await assertFails(
      updateDoc(
        reference(db, 'users/citizen_01'),
        { role: 'official' },
      ),
    );
  });

  it('Afetzede kendisini onaylayamaz', async () => {
    const db = dbAs('citizen_01');

    await assertFails(
      updateDoc(
        reference(db, 'users/citizen_01'),
        { isVerified: true },
      ),
    );
  });

  // --------------------------------
  // 4. Yetkili erişimi
  // --------------------------------

  it('Onaysız yetkili depo okuyamaz', async () => {
    const db = dbAs('official_pending');

    await assertFails(
      getDoc(reference(db, 'warehouses/demo_depo')),
    );
  });

  it('Onaylı yetkili depo okuyabilir', async () => {
    const db = dbAs('official_01');

    await assertSucceeds(
      getDoc(reference(db, 'warehouses/demo_depo')),
    );
  });

  // --------------------------------
  // 5. Lojistik güvenliği
  // --------------------------------

  it('Onaylı yetkili stok miktarını güncelleyebilir', async () => {
    const db = dbAs('official_01');

    await assertSucceeds(
      updateDoc(
        reference(
          db,
          'warehouses/demo_depo/inventory/water',
        ),
        {
          quantity: 100,
          updatedAt: Timestamp.now(),
        },
      ),
    );
  });

  it('Negatif stok miktarı reddedilir', async () => {
    const db = dbAs('official_01');

    await assertFails(
      updateDoc(
        reference(
          db,
          'warehouses/demo_depo/inventory/water',
        ),
        { quantity: -20 },
      ),
    );
  });

  it('Afetzede stok değiştiremez', async () => {
    const db = dbAs('citizen_01');

    await assertFails(
      updateDoc(
        reference(
          db,
          'warehouses/demo_depo/inventory/water',
        ),
        { quantity: 1000 },
      ),
    );
  });

  it('Afetzede stok hareketi oluşturamaz', async () => {
    const db = dbAs('citizen_01');

    await assertFails(
      setDoc(
        reference(
          db,
          'warehouses/demo_depo/movements/movement_01',
        ),
        {
          itemId: 'water',
          type: 'out',
          quantity: 10,
          createdBy: 'citizen_01',
          createdAt: Timestamp.now(),
        },
      ),
    );
  });

  // --------------------------------
  // 6. Yardım çağrısı önceliği
  // --------------------------------

  it('Afetzede doğru öncelikle çağrı oluşturabilir', async () => {
    const db = dbAs('citizen_01');

    await assertSucceeds(
      setDoc(
        reference(db, 'help_requests/request_01'),
        helpRequest(1),
      ),
    );
  });

  it('Afetzede yanlış öncelikle çağrı oluşturamaz', async () => {
    const db = dbAs('citizen_01');

    await assertFails(
      setDoc(
        reference(db, 'help_requests/request_02'),
        helpRequest(3),
      ),
    );
  });

  // --------------------------------
  // 7. Ekip görev durumları
  // --------------------------------

  it('Görev durumu ileri ilerleyebilir', async () => {
    const db = dbAs('official_01');

    await assertSucceeds(
      updateDoc(
        reference(
          db,
          'assignments/assignment_01',
        ),
        {
          status: 'enRoute',
          updatedBy: 'official_01',
          updatedAt: Timestamp.now(),
        },
      ),
    );
  });

  it('Görev durumu geriye alınamaz', async () => {
    const db = dbAs('official_01');

    await assertSucceeds(
      updateDoc(
        reference(
          db,
          'assignments/assignment_01',
        ),
        {
          status: 'enRoute',
          updatedBy: 'official_01',
          updatedAt: Timestamp.now(),
        },
      ),
    );

    await assertFails(
      updateDoc(
        reference(
          db,
          'assignments/assignment_01',
        ),
        {
          status: 'assigned',
          updatedBy: 'official_01',
          updatedAt: Timestamp.now(),
        },
      ),
    );
  });

  // --------------------------------
  // 8. Tahliye anonsları
  // --------------------------------

  function broadcastData(createdBy) {
    return {
      type: 'evacuation',
      title: 'Acil Tahliye',
      body: 'Güvenli alanlara ilerleyin.',
      center: new GeoPoint(36.2, 36.16),
      radiusMeters: 3000,
      createdBy,
      createdAt: Timestamp.now(),
    };
  }

  it('Afetzede tahliye anonsu oluşturamaz', async () => {
    const db = dbAs('citizen_01');

    await assertFails(
      setDoc(
        reference(db, 'broadcasts/broadcast_01'),
        broadcastData('citizen_01'),
      ),
    );
  });

  it('Onaylı yetkili tahliye anonsu oluşturabilir', async () => {
    const db = dbAs('official_01');

    await assertSucceeds(
      setDoc(
        reference(db, 'broadcasts/broadcast_02'),
        broadcastData('official_01'),
      ),
    );
  });

  it('Tahliye yarıçapı 20 km üzerinde olamaz', async () => {
    const db = dbAs('official_01');

    await assertFails(
      setDoc(
        reference(db, 'broadcasts/broadcast_03'),
        {
          ...broadcastData('official_01'),
          radiusMeters: 25000,
        },
      ),
    );
  });
});
