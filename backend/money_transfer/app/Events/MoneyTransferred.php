<?php
// app/Events/MoneyTransferred.php

namespace App\Events;

use App\Models\Transaction;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MoneyTransferred
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public Transaction $transaction;

    /**
     * Create a new event instance.
     */
    public function __construct(Transaction $transaction)
    {
        $this->transaction = $transaction;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('money-transfer.' . $this->transaction->sender_id),
            new PrivateChannel('money-transfer.' . $this->transaction->recipient_id),
        ];
    }

    /**
     * Get the data to broadcast.
     *
     * @return array
     */
    public function broadcastWith(): array
    {
        return [
            'transaction_id' => $this->transaction->id,
            'reference_number' => $this->transaction->reference_number,
            'amount' => $this->transaction->amount,
            'status' => $this->transaction->status,
            'created_at' => $this->transaction->created_at->format('Y-m-d H:i:s'),
        ];
    }
}
