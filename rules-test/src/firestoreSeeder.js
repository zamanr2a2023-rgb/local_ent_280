import { doc, setDoc } from 'firebase/firestore';

export async function seedDocument(testEnv, pathSegments, data) {
  const path = pathSegments.join('/');
  await testEnv.withSecurityRulesDisabled(async (context) => {
    console.info('[rules-test] Seeding document.', { path });
    const db = context.firestore();
    await setDoc(doc(db, ...pathSegments), data);
  });
}
