// import { db, auth } from './firebase.js';

// async function testFirebase() {
//     console.log('Testando conexão com o Firebase...\n');

//     try {
//         const collections = await db.listCollections();
//         console.log('Firestore OK! Coleções encontradas:', collections.map(c => c.id));
//     } catch (err) {
//         console.error('Firestore FALHOU:', err);
//     }

//     try {
//         const listResult = await auth.listUsers(1);
//         console.log('Auth OK! Usuários encontrados:', listResult.users.length);
//     } catch (err) {
//         console.error('Auth FALHOU:', err);
//     }
// }

// testFirebase();
