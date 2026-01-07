import {setGlobalOptions} from "firebase-functions";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

setGlobalOptions({maxInstances: 10});

admin.initializeApp();

export const notifyStockCritical = onDocumentUpdated(
  "users/{userId}/products/{productId}",
  async (event) => {
    if (!event.data) {
      console.log("Evento sem dados.");
      return;
    }

    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    if (!beforeData || !afterData) {
      console.log("before ou after vazio.");
      return;
    }

    const {userId, productId} = event.params;

    const productName = afterData.name ?? "Produto";
    const previousQuantity = beforeData.quantity ?? 0;
    const currentQuantity = afterData.quantity ?? 0;
    const minStock = afterData.minStock ?? 5;
    const productImageUrl = afterData.imageUrl ?? "";

    console.log(
      `[${userId}] Produto ${productId} | ${previousQuantity} → ${currentQuantity}`
    );

    // ⚠️ Determina status da notificação
    let notificationTitle: string | null = null;
    let isCritical = false;
    let isZero = false;

    if (currentQuantity <= 0) {
      notificationTitle = `${productName} esgotado!`;
      isZero = true;
    } else if (currentQuantity <= minStock) {
      notificationTitle = `${productName} em estoque crítico!`;
      isCritical = true;
    }

    // Se não é crítico nem zerado, não envia
    if (!notificationTitle) {
      console.log("Quantidade acima do mínimo, sem notificação.");
      return;
    }

    try {
      // ✅ Busca tokens do usuário
      const tokensSnapshot = await admin
        .firestore()
        .collection(`users/${userId}/fcmTokens`)
        .get();

      if (tokensSnapshot.empty) {
        console.log("Nenhum token FCM para este usuário.");
        return;
      }

      const tokens = tokensSnapshot.docs
        .map((doc) => doc.data().token)
        .filter((token): token is string => typeof token === "string");

      if (tokens.length === 0) {
        console.log("Tokens inválidos ou vazios.");
        return;
      }

      console.log(`Enviando para ${tokens.length} dispositivos`);

      await admin.messaging().sendEachForMulticast({
        tokens,
        notification: {
          title: notificationTitle,
          body: `Quantidade restante: ${currentQuantity}`,
        },
        data: {
          productId: String(productId),
          productName: String(productName),
          quantity: String(currentQuantity),
          isCritical: String(isCritical),
          isZero: String(isZero),
          productImageUrl,
        },
      });

      console.log("Notificações enviadas com sucesso");
    } catch (error) {
      console.error("Erro ao enviar notificações:", error);
    }
  }
);
