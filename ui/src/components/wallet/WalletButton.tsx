"use client";

import React, { useState, useEffect } from "react";
import { WalletMultiButton } from "@solana/wallet-adapter-react-ui";
import { Wallet } from "lucide-react";

const WalletButton: React.FC = () => {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    return (
      <div>
        <button className="!rounded-lg !text-white !h-10 !px-4 !font-medium !transition-colors wallet-adapter-button wallet-adapter-button-trigger">
          <div className="flex items-center gap-2">
            <Wallet className="h-4 w-4" />
            Connect Wallet
          </div>
        </button>
      </div>
    );
  }

  return (
    <div>
      <WalletMultiButton className="!rounded-lg !text-white !h-10 !px-4 !font-medium !transition-colors" />
    </div>
  );
};

export default WalletButton;
