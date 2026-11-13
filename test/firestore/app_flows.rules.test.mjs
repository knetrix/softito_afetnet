import { readFileSync } from 'node:fs';
import { after, before, beforeEach, it } from 'node:test';
import { fileURLToPath } from 'node:url';
import { assertFails, assertSucceeds, initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteField, serverTimestamp, GeoPoint, Timestamp, runTransaction, collection, query, where, getDocs, writeBatch } from 'firebase/firestore';

// Uygulamanın Firestore'a yaptığı gerçek yazımlar (G1–G5 repository'leri)
// kurallarla birlikte denenir. Kural değişince bu dosya da çalıştırılmalı:
//   firebase emulators:exec --only firestore --project demo-afetnet-app-flows \
//     "node --test test/firestore/"
const rulesFile = fileURLToPath(new URL('../../firestore.rules', import.meta.url));

let env;
const OFF = 'off1', CIT = 'cit1', CIT2 = 'cit2';
before(async () => { env = await initializeTestEnvironment({ projectId: 'demo-afetnet-app-flows', firestore: { rules: readFileSync(rulesFile, 'utf8'), host: '127.0.0.1', port: 8080 } }); });
after(async () => env.cleanup());
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (c) => {
    const db = c.firestore();
    await setDoc(doc(db, 'users', OFF), { fullName: 'Y', role: 'official', isVerified: true });
    await setDoc(doc(db, 'users', CIT), { fullName: 'A', role: 'citizen', isVerified: false });
    await setDoc(doc(db, 'users', CIT2), { fullName: 'B', role: 'citizen', isVerified: false });
  });
});
const as = (u) => env.authenticatedContext(u).firestore();
const g = new GeoPoint(36.2, 36.16);

it('1 Kayıt: kullanıcı belgesi + private/contact batch (FirebaseAuthRepository)', async () => {
  const db = env.authenticatedContext('new1').firestore();
  const b = writeBatch(db);
  b.set(doc(db, 'users', 'new1'), { fullName: 'X', role: 'citizen', isVerified: false, notificationsOptIn: true, consents: { privacyVersion: '1', kvkkVersion: '1', acceptedAt: serverTimestamp() }, createdAt: serverTimestamp() });
  b.set(doc(db, 'users', 'new1', 'private', 'contact'), { email: 'x@x.com', phone: '+905321234567' });
  await assertSucceeds(b.commit());
});

it('2 Çağrı gönderimi: Transaction henüz olmayan help_requests/{id} belgesini okur', async () => {
  await assertSucceeds(getDoc(doc(as(CIT), 'help_requests', 'yeni-uuid')));
});

it('3 Çağrı gönderimi tam Transaction (yeni olay + çağrı + private/contact)', async () => {
  const db = as(CIT);
  await assertSucceeds(runTransaction(db, async (tx) => {
    const r = doc(db, 'help_requests', 'req1');
    await tx.get(r);
    const inc = doc(collection(db, 'incidents'));
    tx.set(inc, { location: g, geohash: 'sy3tyy6u', type: 'debris', priority: 1, requestCount: 1, primaryRequestId: 'req1', status: 'pending', isOpen: true, createdAt: serverTimestamp(), updatedAt: serverTimestamp() });
    tx.set(r, { createdBy: CIT, type: 'debris', priority: 1, status: 'pending', peopleCount: 1, location: g, geohash: 'sy3tyy6u', photoUrls: [], incidentId: inc.id, createdOffline: false, createdAt: serverTimestamp() });
    tx.set(doc(db, 'help_requests', 'req1', 'private', 'contact'), { fullName: 'A', phone: '+90' });
  }));
});

it('4 Yeni panik eski "Ulaşıldı" kaydını siler (sahibi handledBy/handledAt silebilir)', async () => {
  await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), 'safety_signals', CIT), { state: 'danger', location: g, geohash: 'sy3tyy6u', updatedAt: Timestamp.now(), handledBy: OFF, handledAt: Timestamp.now() }));
  await assertSucceeds(setDoc(doc(as(CIT), 'safety_signals', CIT), { state: 'danger', location: g, geohash: 'sy3tyy6u', updatedAt: serverTimestamp(), handledBy: deleteField(), handledAt: deleteField() }, { merge: true }));
});

it('5 İlk panik (belge yok) — uygulama deleteField ile merge yazar', async () => {
  await assertSucceeds(setDoc(doc(as(CIT), 'safety_signals', CIT), { state: 'danger', location: g, geohash: 'sy3tyy6u', updatedAt: serverTimestamp(), handledBy: deleteField(), handledAt: deleteField() }, { merge: true }));
});

it('6 GÜVENDEYİM ("Ulaşıldı" kaydı olan belgede)', async () => {
  await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), 'safety_signals', CIT), { state: 'danger', location: g, geohash: 'sy3tyy6u', updatedAt: Timestamp.now(), handledBy: OFF, handledAt: Timestamp.now() }));
  await assertSucceeds(setDoc(doc(as(CIT), 'safety_signals', CIT), { state: 'safe', updatedAt: serverTimestamp() }, { merge: true }));
});

async function seedAssigned(extraPending) {
  await env.withSecurityRulesDisabled(async (c) => {
    const db = c.firestore();
    await setDoc(doc(db, 'incidents', 'inc1'), { location: g, geohash: 'sy3tyy6u', type: 'debris', priority: 1, requestCount: 2, primaryRequestId: 'r1', status: 'assigned', isOpen: true, assignedTeamId: 't1', createdAt: Timestamp.now() });
    await setDoc(doc(db, 'help_requests', 'r1'), { createdBy: CIT, type: 'debris', priority: 1, status: 'assigned', assignedTeamId: 't1', incidentId: 'inc1', location: g, geohash: 'sy3tyy6u', createdAt: Timestamp.now() });
    if (extraPending) await setDoc(doc(db, 'help_requests', 'r2'), { createdBy: CIT2, type: 'medical', priority: 1, status: 'pending', incidentId: 'inc1', location: g, geohash: 'sy3tyy6u', createdAt: Timestamp.now() });
    await setDoc(doc(db, 'assignments', 'a1'), { incidentId: 'inc1', teamId: 't1', status: 'assigned', assignedBy: OFF, updatedBy: OFF, createdAt: Timestamp.now() });
    await setDoc(doc(db, 'teams', 't1'), { name: 'T', status: 'onDuty', currentTask: 'inc1' });
  });
}
async function advance(next, resolved) {
  const db = as(OFF);
  const linked = await getDocs(query(collection(db, 'help_requests'), where('incidentId', '==', 'inc1')));
  return runTransaction(db, async (tx) => {
    await tx.get(doc(db, 'assignments', 'a1'));
    const snaps = []; for (const d of linked.docs) snaps.push(await tx.get(d.ref));
    tx.update(doc(db, 'assignments', 'a1'), { status: next, updatedBy: OFF, updatedAt: serverTimestamp() });
    tx.update(doc(db, 'incidents', 'inc1'), { status: next, updatedAt: serverTimestamp(), ...(resolved ? { isOpen: false, resolvedAt: serverTimestamp() } : {}) });
    for (const s of snaps) { const st = s.data().status; if (st === 'cancelled' || st === 'resolved') continue;
      tx.update(s.ref, { status: next, assignedTeamId: 't1', updatedAt: serverTimestamp(), ...(resolved ? { resolvedAt: serverTimestamp() } : {}) }); }
    tx.update(doc(db, 'teams', 't1'), { status: resolved ? 'available' : 'onDuty', currentTask: resolved ? deleteField() : 'inc1', updatedAt: serverTimestamp() });
  });
}
it('7 Görev ilerletme (G5 advanceAssignment, tek çağrı)', async () => { await seedAssigned(false); await assertSucceeds(advance('enRoute', false)); });
it('8 Görev ilerletme: atamadan sonra birleşen bekleyen çağrı varken', async () => { await seedAssigned(true); await assertSucceeds(advance('enRoute', false)); });

it('9 Ekip ata (G5 assignTeam)', async () => {
  await env.withSecurityRulesDisabled(async (c) => {
    const db = c.firestore();
    await setDoc(doc(db, 'incidents', 'inc1'), { location: g, geohash: 'sy3tyy6u', type: 'debris', priority: 1, requestCount: 1, primaryRequestId: 'r1', status: 'pending', isOpen: true, createdAt: Timestamp.now() });
    await setDoc(doc(db, 'help_requests', 'r1'), { createdBy: CIT, type: 'debris', priority: 1, status: 'pending', incidentId: 'inc1', location: g, geohash: 'sy3tyy6u', createdAt: Timestamp.now() });
    await setDoc(doc(db, 'teams', 't1'), { name: 'T', status: 'available' });
  });
  const db = as(OFF);
  await assertSucceeds(runTransaction(db, async (tx) => {
    await tx.get(doc(db, 'incidents', 'inc1')); await tx.get(doc(db, 'teams', 't1')); await tx.get(doc(db, 'help_requests', 'r1'));
    tx.set(doc(collection(db, 'assignments')), { incidentId: 'inc1', teamId: 't1', status: 'assigned', assignedBy: OFF, updatedBy: OFF, createdAt: serverTimestamp(), updatedAt: serverTimestamp() });
    tx.update(doc(db, 'incidents', 'inc1'), { status: 'assigned', assignedTeamId: 't1', updatedAt: serverTimestamp() });
    tx.update(doc(db, 'help_requests', 'r1'), { status: 'assigned', assignedTeamId: 't1', updatedAt: serverTimestamp() });
    tx.update(doc(db, 'teams', 't1'), { status: 'onDuty', currentTask: 'inc1', updatedAt: serverTimestamp() });
  }));
});

it('10 Ulaşıldı (yetkili)', async () => {
  await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), 'safety_signals', CIT), { state: 'danger', location: g, geohash: 'sy3tyy6u', updatedAt: Timestamp.now() }));
  await assertSucceeds(updateDoc(doc(as(OFF), 'safety_signals', CIT), { handledBy: OFF, handledAt: serverTimestamp() }));
});

it('11 Afetzede iptal', async () => {
  await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), 'help_requests', 'r1'), { createdBy: CIT, type: 'debris', priority: 1, status: 'pending', location: g, geohash: 'sy3tyy6u', createdAt: Timestamp.now() }));
  await assertSucceeds(updateDoc(doc(as(CIT), 'help_requests', 'r1'), { status: 'cancelled' }));
});

it('12 Afetzede kart sorgusu (createdBy) ve olay okuma', async () => {
  await assertSucceeds(getDocs(query(collection(as(CIT), 'help_requests'), where('createdBy', '==', CIT))));
  await assertSucceeds(getDoc(doc(as(CIT), 'incidents', 'x')));
  await assertSucceeds(getDoc(doc(as(CIT), 'teams', 'x')));
});

it('13 Hesabı Sil batch', async () => {
  await env.withSecurityRulesDisabled(async (c) => { const db = c.firestore();
    await setDoc(doc(db, 'help_requests', 'r1'), { createdBy: CIT, status: 'pending' });
    await setDoc(doc(db, 'help_requests', 'r1', 'private', 'contact'), { fullName: 'A' });
    await setDoc(doc(db, 'safety_signals', CIT), { state: 'safe' });
    await setDoc(doc(db, 'users', CIT, 'private', 'contact'), { email: 'a' }); });
  const db = as(CIT); const b = writeBatch(db);
  b.delete(doc(db, 'help_requests', 'r1', 'private', 'contact')); b.delete(doc(db, 'safety_signals', CIT)); b.delete(doc(db, 'users', CIT, 'private', 'contact')); b.delete(doc(db, 'users', CIT));
  await assertSucceeds(b.commit());
});

it('14 Profil güncelleme (ad, bildirim tercihi)', async () => {
  await assertSucceeds(updateDoc(doc(as(CIT), 'users', CIT), { fullName: 'Yeni', notificationsOptIn: true }));
});

it('15 Afetzede başkasının çağrısını okuyamaz', async () => {
  await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), 'help_requests', 'r1'), { createdBy: CIT2, status: 'pending' }));
  await assertFails(getDoc(doc(as(CIT), 'help_requests', 'r1')));
});

it('16 Sahibi Ulaşıldı kaydını yazamaz/değiştiremez', async () => {
  await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), 'safety_signals', CIT), { state: 'danger', location: g, geohash: 'sy3tyy6u', updatedAt: Timestamp.now() }));
  await assertFails(setDoc(doc(as(CIT), 'safety_signals', CIT), { handledBy: CIT, handledAt: serverTimestamp() }, { merge: true }));
  await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), 'safety_signals', CIT), { handledBy: OFF, handledAt: Timestamp.now() }, { merge: true }));
  await assertFails(setDoc(doc(as(CIT), 'safety_signals', CIT), { handledBy: CIT }, { merge: true }));
});

it('17 Yetkili olayı bekliyor durumundan doğrudan Yola Çıktı yapamaz', async () => {
  await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), 'incidents', 'inc1'), { status: 'pending', isOpen: true, priority: 1 }));
  await assertFails(updateDoc(doc(as(OFF), 'incidents', 'inc1'), { status: 'enRoute' }));
});

it('18 Yetkili iptal edilmiş çağrıya dokunamaz', async () => {
  await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), 'help_requests', 'r1'), { createdBy: CIT, status: 'cancelled' }));
  await assertFails(updateDoc(doc(as(OFF), 'help_requests', 'r1'), { status: 'onSite' }));
});

it('19 Çağrı gönderimi: açık olaya birleşir (requestCount +1, öncelik yükselir)', async () => {
  await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), 'incidents', 'inc1'), { location: g, geohash: 'sy3tyy6u', type: 'water', priority: 3, requestCount: 1, primaryRequestId: 'r0', status: 'pending', isOpen: true, createdAt: Timestamp.now() }));
  const db = as(CIT2);
  await assertSucceeds(runTransaction(db, async (tx) => {
    const r = doc(db, 'help_requests', 'req2');
    await tx.get(r);
    const inc = doc(db, 'incidents', 'inc1');
    await tx.get(inc);
    tx.update(inc, { requestCount: 2, priority: 1, updatedAt: serverTimestamp() });
    tx.set(r, { createdBy: CIT2, type: 'medical', priority: 1, status: 'pending', peopleCount: 1, location: g, geohash: 'sy3tyy6u', photoUrls: [], incidentId: 'inc1', createdOffline: false, createdAt: serverTimestamp() });
    tx.set(doc(db, 'help_requests', 'req2', 'private', 'contact'), { fullName: 'B', phone: '+90' });
  }));
});
