import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createHmac } from "https://deno.land/std@0.168.0/node/crypto.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Constants from environment variables
const RAZORPAY_WEBHOOK_SECRET = Deno.env.get("RAZORPAY_WEBHOOK_SECRET")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Initialize Supabase Client with Admin privileges
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req) => {
  try {
    // 1. Verify the HTTP Method
    if (req.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405 });
    }

    // 2. Read the raw body and the Razorpay signature header
    const bodyText = await req.text();
    const signature = req.headers.get("x-razorpay-signature");

    if (!signature) {
      return new Response("Missing Razorpay Signature", { status: 400 });
    }

    // 3. Verify the Signature using HMAC SHA256
    const expectedSignature = createHmac("sha256", RAZORPAY_WEBHOOK_SECRET)
      .update(bodyText)
      .digest("hex");

    if (expectedSignature !== signature) {
      console.error("Invalid webhook signature.");
      return new Response("Invalid Signature", { status: 400 });
    }

    // 4. Parse the payload
    const payload = JSON.parse(bodyText);
    const event = payload.event;
    const paymentEntity = payload.payload.payment.entity;

    console.log(`Received secure webhook event: ${event}`);

    // 5. Handle the payment.captured event (Business deposited funds to Escrow)
    if (event === "payment.captured") {
      const amountInRupees = paymentEntity.amount / 100; // Razorpay amounts are in paise
      const businessId = paymentEntity.notes?.business_id;
      const campaignId = paymentEntity.notes?.campaign_id;

      if (!businessId || !campaignId) {
         console.warn("Payment missing business_id or campaign_id notes. Skipping ledger update.");
         return new Response("Missing metadata", { status: 200 });
      }

      // 6. Update the Escrow Balance in Database
      const { error: txError } = await supabase
        .from('wallet_transactions')
        .insert({
          user_id: businessId,
          amount: amountInRupees,
          type: 'escrow_hold',
          description: `Escrow deposit for Campaign ${campaignId}`,
          reference_id: paymentEntity.id,
          status: 'completed'
        });

      if (txError) throw txError;

      // Increment campaign escrow balance
      const { data: currentCamp } = await supabase
        .from('campaigns')
        .select('escrow_balance')
        .eq('id', campaignId)
        .single();
        
      if (currentCamp) {
         await supabase.from('campaigns')
           .update({ escrow_balance: currentCamp.escrow_balance + amountInRupees })
           .eq('id', campaignId);
      }

      console.log(`Successfully credited ₹${amountInRupees} to Campaign ${campaignId} Escrow.`);
    }

    // 6. Respond 200 OK to Razorpay
    return new Response(JSON.stringify({ status: "success" }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error) {
    console.error("Webhook processing error:", error);
    return new Response(JSON.stringify({ error: "Internal Server Error" }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
});
